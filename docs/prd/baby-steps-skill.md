# baby-steps skill

## Goal

Új skill a `dev-skills` pluginban `baby-steps` néven: az implementációt az agenttel apró, egyenként jóváhagyott lépésekben lehet végigvinni, a lépések indoklásával együtt. A végén nincs 600 soros diff, amit egyben kell reviewolni.

## Problem

Ha az agent egyben megírja a változást, a felhasználó csak a végén, a review során találkozik vele, és ott két gond jelentkezik egyszerre:

- a diff túl nagy ahhoz, hogy érdemben át lehessen nézni;
- nem látszik, miért olyan a kód, amilyen: a döntések indoka elveszik.

A skill célja, hogy a review menet közben, lépésenként történjen meg, a miértekkel együtt.

## Users and journeys

Felhasználó: a fejlesztő, aki egy agenttel dolgozik egy implementáción, és kézben akarja tartani, mi kerül be a kódba.

Egy lépés menete:

1. A skill bemenete egy tetszőleges feladat. Ha van PRD vagy vertical-slice terv, abból dolgozik, ha nincs, a leírásból.
2. Az agent **csak a következő lépést** javasolja, teljes lépéslista nélkül.
3. Leírja, **mit és miért** fog csinálni.
4. Megmutatja a tervezett változást (diffet), de **nem módosít semmit**, amíg nincs jóváhagyás.
5. A felhasználó válaszol:
   - **Jóváhagyom**: az agent alkalmazza a változást. Commit ilyenkor nem készül.
   - **Módosítást kérek**: az agent átdolgozza és újra megmutatja.
   - **Elvetem**: az agent másik megközelítést javasol.
   - **Átugrás / nagyobb lépés engedélyezése erre a részre**: az agent az adott résznél nagyobb lépést is tehet.
6. Alkalmazás után lefut a releváns teszt vagy build, és az agent jelenti az eredményt.
7. Ha összeállt egy nagyobb logikai egység, az agent **commitot javasol**. A commit külön lépés, külön jóváhagyással.
8. A ciklus **megszakítás nélkül** a következő lépéssel folytatódik: az agent a lépés alkalmazása és ellenőrzése után **ugyanabban a körben magától** megmutatja a következő lépést, nem vár külön felszólításra.
9. A ciklus akkor ér véget, amikor a feladat (vagy a PRD / terv aktuális szelete) **minden pontja** megvan. Ha az agent nem biztos benne, mi a következő lépés, **nem áll meg csendben**, hanem célzott kérdést tesz fel a felhasználónak.

## In scope

- Új `SKILL.md`: `plugins/dev-skills/skills/baby-steps/SKILL.md`, angol nyelven, mint a többi skill. Az agent a felhasználó nyelvén kommunikál.
- Bejegyzés a `README.md` skill-táblázatába.
- Lépésméret: egy logikai változás, jellemzően 20 sor vagy kevesebb. Példák: egy függvény hozzáadása, egy endpoint boilerplate-je, egy új `if` ág.
- Teszt-először szemlélet: a teszt jellemzően külön baby step, a következő lépés teszi zölddé. A lépések **nem követik szigorúan a TDD fázisait**, és nem kell mindegyiknek zöld teszttel végződnie: a köztes piros állapot elfogadott.
- Minden alkalmazott lépés után a releváns tesztek vagy a build futtatása, az eredmény jelentése (a piros eredmény is csak információ, nem hiba).
- Jóváhagyás kérése abban a formában, ami az adott környezetben elérhető. Az `AskUserQuestion` az előnyben részesített, ha van.
- Commit javasolása nagyobb logikai egység után, külön lépésként.

- Folytonosság: az agent csak két helyzetben áll meg: jóváhagyásra vár, vagy a feladat kész. Jóváhagyás és alkalmazás után sosem marad ott, hogy a felhasználónak kelljen szólni a folytatáshoz.

## Out of scope

- A feladat PRD-vé vagy vertical slice-okra bontása (ezt a `clarify` és a `vertical-slice` skill végzi).
- Teljes, előre rögzített lépéslista vagy haladási tábla vezetése.
- Automatikus commit jóváhagyás után.
- Kódreview a végén (a skill célja éppen ennek kiváltása).

## Success criteria

- Nincs olyan diff, amit a felhasználó egyben, indoklás nélkül kapna meg: minden változás egy javasolt, megindokolt lépésként érkezik.
- Jóváhagyás előtt a fájlrendszer nem változik.
- Egy tipikus lépés diffje nagyjából 20 sor vagy kisebb, akkor is, ha emiatt a teszt köztesen piros marad.
- A felhasználó minden lépésnél látja a miértet, és a négy válasz (jóváhagy, módosít, elvet, nagyobb lépés) mindegyike kezelve van.
- A fejlesztés közben az agent nem áll meg a feladat befejezése előtt: alkalmazott lépés után mindig vagy a következő lépés jön, vagy célzott kérdés, vagy a "kész" jelzés a hiányzó pontok nélkül.
- Commit csak külön javaslatra és külön jóváhagyás után készül.

## Constraints

- A repo konvenciója: `plugins/<plugin>/skills/<név>/SKILL.md`, frontmatterrel (`name`, `description`).
- A skill környezetfüggetlen: irodán kívül is működnie kell, ezért nem függhet az `office-ask`-tól.

## Open questions and assumptions

Feltevések (a kód vagy az észszerű alapértelmezés eldönti, nem kérdéses):

- A "nagyobb lépés engedélyezése" az adott résznél érvényes, a következő témánál az agent visszatér a kis lépésekhez.
- Ha egy lépés után a teszt piros, az agent ezt jelenti, és a következő kis lépést javasolja (akár a javítást, akár a tervezett folytatást), nem módosít csendben. **Piros teszt miatt soha nem javasol nagyobb változtatást**: a kis, könnyen átnézhető lépések elve erősebb, mint a zöld állapot.
- A diff megmutatása szövegesen történik (kódblokk), nem kell hozzá külön eszköz.
- Egy kérés kapcsán nincs nyitott kérdés, amit a felhasználó még meg tudna válaszolni.
