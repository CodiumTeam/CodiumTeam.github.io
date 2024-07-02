---
layout: post
title:  "A DBT Journey"
date:   2024-07-02 09:00:00 +0200
author: hugo
categories: codium
read_time : 15
---


If you have a subscription based business you will realize that the best predictor of subscription renewal is the amount of use a user makes of your service.
Here is an example of an e-learning platform based on lessons completed by month.


| Lessons completed by month | Renewal  |
|:---------------------------|:---------|
| 0                          | 12%      |
| 0-4                        | 53%      |
| 4-12                       | 66%      |
| 12+                        | 71%      |

Being able to monitor the user engagement with your platform will allow you to take actions to improve user retention, some examples of this actions can be gamification or sending push notifications.
Being able to track the effect of changes over allow businesses to make data-driven decisions.

Here is an example of a dashboard showing how user interactions decrease over time after signup, being able to monitor this data is key to take actions to increase user satisfaction.  

<img class="centered" alt="" src="/img/post-assets/dbt-journey/engagement-by-week.jpg" height="240"/>

We were recently tasked with creating such dashboard using Google's Looker Studio, here is the story of how we did it.

## The data model


The task looks easy at first glance, until you realize that the data model is less than ideal for writing the queries that return the data we need.

In an ideal scenario, the subscriptions table would look something like this:


| id | user\_id | start | end        | status    |
| :--- | :--- | :--- |:-----------|:----------|
| 101489 | 21007 | 2022-10-12 | 2023-10-20 | cancelled |
| 108312 | 21014 | 2022-10-21 | 2024-03-08 | expired   |
| 110266 | 21027 | 2022-10-25 | null       | active    |



But instead, WooCommerce stores user subscriptions as custom post types, using a post meta table to add custom fields on them, as the start date of a subscription, the end date, the renewal date, etc.

Here is a subset of the posts table:

| ID | post\_date | post\_status | post\_parent | post\_type | post\_title |
|:---| :--- | :--- |:-------------| :--- | :--- |
| 2  | 2024-07-01 22:08:24 | wc-active | 1            | shop\_subscription | Suscripción &ndash; 1 de July de 2024, 8:08 PM |
| 1  | 2024-07-01 22:08:24 | wc-completed | 0            | shop\_order | Order &ndash; julio 1, 2024 @ 10:08 PM |


And here an example of some related post metas:


| meta_id | post_id | meta_key        | meta_value          |
|:--------|:--------|:----------------|:--------------------|
| 1       | 2       | _schedule_start | 2024-07-01 00:45:18 |
| 2       | 2       | _schedule_end   | 2025-07-01 00:45:18 |
| 3       | 2       | _customer_user  | 123                 |



We can use the `WITH` clause to reformat this data in a friendlier manner, and then query over the created alias, but preparing all the information this way would make our queries very complicated and would result in lots of duplicated code for various reports. So instead we decided on using **DBT** to transform the data into **materialized views**. 

We worked with DBT some months ago while working for another client (one of the best things of working on consultancy and having many clients is that you get exposed to lots of technologies).

This was a perfect use case for DBT, the original data model needed some transformations to make it usable, we can write some queries to transform the data and DBT will use this queries (now called models in DBT jargon) to build materialized views.
Not only will this make our reports faster, we can define incremental strategies to import new data as time passes, not having to rebuild the views from scratch makes refreshing the data superfast.

DBT also allows us to write tests over our models, allowing us to validate assumptions, this allows us to make sure we have a good understanding of the data model and that our assumptions remain true in the future when the wordpress instance and it’s plugins get updates that may make changes to the data model.
Writing tests, is one of our core-values, so of course we made good use of this feature.

### Step 1: defining the subscription model

We created a simple model to unify all subscription data in a single row, making it easier to index it and query against it.

The model query looks something like this, in reality is a little bit more complex because we need to get some more data to create some filters in the final report, like categorizing the users by country, language, subscription modality, etc.

```sql
-- filename=subscriptions.sql
{% raw %}
{{ config(materialized='table') }}
{% endraw %}

select
   subscription.ID as id,
   customer.meta_value as user_id,
   postmeta_start.meta_value as start,
   postmeta_end.meta_value as end,
   subscription.post_status as status
from wp_posts as subscription

-- join with order to filter out checkout carts that where left unfinished
inner join wp_posts as payment_order
   on subscription.post_parent = payment_order.ID
  and payment_order.post_status = 'wc-completed'

-- join with metas to get subscription start date
inner join wp_postmeta as postmeta_start
   on postmeta_start.meta_key = '_schedule_start'
  and postmeta_start.post_id = subscription.ID

-- join with metas to get subscription end date       
inner join wp_postmeta as postmeta_end
   on postmeta_end.meta_key = '_schedule_end'
  and postmeta_end.post_id = subscription.ID

-- join with metas to get the user ID that purchased the subscription       
inner join wp_postmeta as customer
   on customer.meta_key = '_customer_user'
  and customer.post_id = subscription.ID

-- only subscriptions with valid status stored as wordpress posts   
where subscription.post_type = 'shop_subscription'
 and subscription.post_status IN ('wc-active', 'wc-cancelled', 'wc-expired', 'wc-pending-cancel')
 ```


### Step 2: create the activity model

To get the engagement report we also need to know the user activity, we need to find traces of users using the e-learning platform. Fortunately, learndash uses custom tables instead of trying to cram all the information into custom post types as wooCommerce does, so it’s much easier to get what we need.

```sql
-- filename=activities.sql
{% raw %}
{{ config(materialized='incremental') }}
{% endraw %}

select
   user_id,
   -- learndash stores dates as timestamps that need to be converted to the same date format as subscriptions
   date(from_unixtime(activity_completed)) as date
from wp_learndash_user_activity
where activity_completed > 0
{% raw %}
{% if is_incremental() %}
  and activity_completed >= (
    -- get greatest event date already imported into the materialized table
    select unix_timestamp(coalesce(max(date), '2000-01-01')) from {{ this }}
  )
{% endif %}
{% endraw %}
```

wohoooo!, we now have the user signups and the user activities, we are ready to create the report, aren’t we?


### Step 3: create a date spine

Well, not quite. Remember the table shown above? We need to group the users in weekly cohorts and the activities into weekly groups over the next weeks after the signup.

It has to show the number of users that purchased a subscription each week and then monitor how many of them are still active after 12 weeks, seeing the numbers week after week.

To aggregate the data by week we will create a date spine table. A date spine is just a table filled with dates that we can use to group our signups and activities by date periods in order to count them.

I will create this date spine with the following query:

```sql
# filename=calendar_weeks.sql
{% raw %}
{{ config(materialized='table') }}
{% endraw %}

select
   min(gen_date) as first_day,
   date_add(min(gen_date), interval 6 day) as last_day,
   floor(datediff(gen_date, '2018-01-01')/7) as week_id
from
(select adddate('1970-01-01',t4*10000 + t3*1000 + t2*100 + t1*10 + t0) gen_date from
(select 0 t0 union select 1 union select 2 union select 3 union select 4 union select 5 union select 6 union select 7 union select 8 union select 9) t0,
(select 0 t1 union select 1 union select 2 union select 3 union select 4 union select 5 union select 6 union select 7 union select 8 union select 9) t1,
(select 0 t2 union select 1 union select 2 union select 3 union select 4 union select 5 union select 6 union select 7 union select 8 union select 9) t2,
(select 0 t3 union select 1 union select 2 union select 3 union select 4 union select 5 union select 6 union select 7 union select 8 union select 9) t3,
(select 0 t4 union select 1 union select 2 union select 3 union select 4 union select 5 union select 6 union select 7 union select 8 union select 9) t4) v
where gen_date between '2018-01-01' and '2025-12-31'
group by week_id
order by first_day asc
```

This will produce a table with an ever-increasing week identifier and the date ranges for every week.
We need the week number to be something that does not reset between years, and we also want to be able to subtract the ids to get the amount of weeks between ranges that's why we did not use the `week()`.


| first\_day | last\_day | week\_id |
| :--- | :--- | :--- |
| 2018-01-01 | 2018-01-07 | 0 |
| 2018-01-08 | 2018-01-14 | 1 |
| 2018-01-15 | 2018-01-21 | 2 |
| 2018-01-22 | 2018-01-28 | 3 |
| 2018-01-29 | 2018-02-04 | 4 |


### Step 4: aggregate data by weekly periods

Now we need to put all the data together. 

```sql
-- filename=engagement_by_week.sql

with new_users as (
    select subscriptions.id,
           cal.first_day,
           null as weeks_after_signup
    from
        {{ ref('subscriptions') }} as subscriptions,
        {{  ref('calendar_weeks') }} as cal
    where subscriptions.start between cal.first_day and cal.last_day
      and cal.last_day < curdate()
    group by 1,2,3
),
active_users as (
    select
        subscription.id,
        subscription_periods.first_day,
        (activity_periods.week_id - subscription_periods.week_id) as weeks_after_signup
    from
        {{ ref("user_activity") }} as activity,
        {{ ref("calendar_weeks") }} as activity_periods,
        {{ ref("subscriptions") }} as subscription,
        {{ ref("calendar_weeks") }} as subscription_periods
    where activity.date between activity_periods.first_day and activity_periods.last_day
      and subscription.start between subscription_periods.first_day and subscription_periods.last_day
      and activity.user_id = subscription.user_id
      and activity.date >= subscription.start
      -- limit data to last whole day
      and subscription_periods.last_day < curdate()
      -- get only activities after the subscription started
      and activity_periods.week_id >= subscription_periods.week_id
      -- only during the next 12 weeks after signup
      and (activity_periods.week_id - subscription_periods.week_id) <= 12
    group by 1,2,3
)

```


This model will generate the data ready for Looker to import it and create a pivot table.


### Step 5: render the table with SQL

Explaining how to create the pivot table in Looker Studio is a bit complex, instead I will show you how to use DBT to create a table with the same information (it will lack the filters but you can modify it as you need).


```sql
-- filename=engagement_by_week_cohort_view.sql
{% raw %}
select
    first_day,
    -- create a column with the total signups in a period
    sum(case when isnull(weeks_after_signup) then 1 else 0 end) as new_users,
    -- create the columns for next following 12 weeks
    {% for i in range(1,13) %}
        -- show zeros as null
        nullif(
            -- count users that had at least one activity during the period
            sum(case when weeks_after_signup = {{ i }} then 1 else 0 end), 0
        ) as week_{{ i }}
        -- add a comma only if not last loop
        {{ ", " if not loop.last else "" }}
    {% endfor %}
from
    {{ ref('engagement_by_week') }}
group by first_day
order by first_day asc
{% endraw %}
```

Well, this sums it all.

This is an oversimplification of the real project, there are lots of nuances and extra requirements in the project to allow filtering by many dimensions to gather the required business intelligence that was requested.
This post only want to be a showcase of how DBT can be leveraged to extract information from any model and make it into a more suitable reporting format.

If you want to make something similar, contact us. We can help you build your BI dashboards to help you make your business thrive.
