---
layout: post
title:  "Simplicidad"
date:   2023-08-17 11:00:00 +0100
author: luis
categories: codium
feature_image: post-assets/simplicity
read_time : 5
---
Es difícil quedarme sólo con un [valor de eXtreme Programming](http://www.extremeprogramming.org/values.html), pues todos me parecen importantes y complementarios. No obstante, últimamente veo muchísima complejidad innecesaria en el código que no hace más que provocar dolor en los programadores, producir errores en producción y generar más complejidad.

Si tuviera que quedarme con un valor sería **simplicidad**.

Empecemos haciendo las cosas simples y luego, si es realmente necesario, vayamos complicando el sistema. Para mí es importante que la complejidad venga de una necesidad real y no de un capricho o de un "por si acaso".

Recuerdo hace años que después de “refactorizar” la [kata de 99 bottles of beer](http://www.99-bottles-of-beer.net/lyrics.html) me paré a pensar y a compararla con la versión “sin refactorizar” y tuve una pequeña revelación: lucha fuerte por la simplicidad.

Versión refactorizada:
```php
class Song
{
    const MAX_BOTTLES = 99;

    public function song(): array
    {
        $sentences = [];
        for ($i = 0; $i <= self::MAX_BOTTLES; $i++) {
            $numberOfBottles = self::MAX_BOTTLES - $i;
            $sentences[] = $this->firstVerseOfStrophe($numberOfBottles);
            $sentences[] = $this->secondVerseOfStrophe($numberOfBottles);
        }
        return $sentences;
    }

    public function firstVerseOfStrophe(int $numberOfBottles): string
    {
        return $this->verse(
            $this->bottlesOnTheWall($numberOfBottles),
            $this->bottlesOfBeer($numberOfBottles)
        );
    }

    public function secondVerseOfStrophe($numberOfBottles): string
    {
        return $this->verse(
            $this->action($numberOfBottles),
            $this->bottlesOnTheWall($numberOfBottles - 1)
        );
    }

    private function verse(string $firstSentence, string $secondSentence): string
    {
        return ucfirst($firstSentence) . ', ' . $secondSentence . '.';
    }

    public function bottlesOnTheWall(int $numberOfBottles): string
    {
        return $this->bottlesOfBeer($numberOfBottles) . " on the wall";
    }

    private function bottlesOfBeer(int $numberOfBottles)
    {
        return $this->bottles($numberOfBottles) . " of beer";
    }

    private function bottles(int $numberOfBottles): string
    {
        if ($numberOfBottles === 0) {
            return "no more bottles";
        } elseif ($numberOfBottles === 1) {
            return "1 bottle";
        } elseif ($numberOfBottles === -1) {
            return "99 bottles";
        }
        return "$numberOfBottles bottles";
    }

    public function action(int $numberOfBottles): string
    {
        if ($numberOfBottles === 0) {
            return 'Go to the store and buy some more';
        }
        return "Take one down and pass it around";
    }

    public function sing(): void
    {
        foreach ($this->song() as $sentence) {
            echo "$sentence\n";
        }
    }
}
```
<br />  
Versión sin refactorizar:
```php
class Song
{
    public function song(): array
    {
        $sentences = [];
        for ($i = 99; $i >= 2; $i--) {
            $sentences[] = "$i bottles of beer on the wall, $i bottles of beer.";
            $sentences[] = "Take one down and pass it around, " . ($i-1) . " bottles of beer on the wall.";
        }
        $sentences[] = "1 bottle of beer on the wall, 1 bottle of beer.";
        $sentences[] = "Take one down and pass it around, no more bottles of beer on the wall.";
        $sentences[] = "No more bottles of beer on the wall, no more bottles of beer.";
        $sentences[] = "Go to the store and buy some more, 99 bottles of beer on the wall.";
        return $sentences;
    }

    public function sing()
    {
        foreach ($this->song() as $sentence){
            echo "$sentence\n";
        }
    }
}
```
<br />
Quizás no estés de acuerdo conmigo y pienses que la versión refactorizada es mejor porque utiliza el lenguaje de negocio (versos, estrofas, …), no hay duplicidad, etc. Son buenos argumentos pero, en mi opinión, hay que balancearlos.

Si lo miras desde el enfoque de cuánto esfuerzo cuesta:
cambiar el código a alguien que no lo ha visto antes
encontrar un error en el código
traducirlo
…
creo que estarás de acuerdo que la versión sin refactorizar es mucho más simple.

Mi sensación es que parte de ese miedo que tenemos a refactorizar, se debe a que, por una parte, no estamos acostumbrados a hacerlo y no tenemos suficientes tests que nos den la confianza necesaria para realizar los cambios. A esto se suma el hecho de que no siempre tenemos clara cuál va a ser la dirección del refactor.

Ese miedo a refactorizar nos obliga a anticiparnos, a tratar de prever lo que va a ocurrir y acabamos haciendo muchas cosas "por si acaso". Eso es lo que nos añade mucha complejidad innecesaria, que ralentiza el desarrollo y la mayoría de las veces no aporta valor.



