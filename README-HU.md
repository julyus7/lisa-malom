# Malom – Apple Lisa 2

Magyar, natív, ablakban futó kilenckorongos Malom Lisa Office System 3
rendszerhez, valódi Apple Lisa 2 géphez és LisaEm-hez.

## Indítás

A kész fájl: **Malom.dc42**. Először indítsd a LOS 3 rendszert.
LisaEm-ben helyezd be a DC42 lemezképet, nyisd meg a lemez ablakát, jelöld ki
a Malom ikont és válaszd a File/Print → Open műveletet.
Valódi Lisa 2-höz a lemezképet Lisa-formátumú 400 KB-os floppyra kell kiírni,
a natív szektorcímkéket megőrizve, vagy megfelelő Lisa-floppyhelyettesítővel
használni. A LOS Duplikálás műveletével a Games mappába is telepíthető.
A másolás végéig maradjon bent a floppy.

Saját eszközazonosító: **244**, lemezazonosító vége: **D605**, saját malomikon.

## Kezelés

- Egér: kattints a mezőre. Lépéskor először a saját korongot, majd a célmezőt.
- Billentyűzet: írd be a mező számát (1–24), majd Enter. Lépéskor külön
  add meg a kiinduló és a célmezőt.
- **G**: új játék a gép ellen; a felhasználó világos, a gép fekete.
- **K**: új kétjátékos játék.
- **N**: új játék a jelenlegi módban.
- **Esc / Backspace**: a kijelölés és a beírt mező törlése.

A világos kezd. A mezőszámok mindig láthatók. A kijelölt korongot külső
gyűrű jelzi; levételkor a levehető ellenséges korongok kapnak gyűrűt.
A feliratok a Lisa betűkészlete miatt ékezet nélküliek.

## Szabályok

1. Mindkét játékos kilenc korongot rak le, felváltva egyet egy üres mezőre.
2. Három saját korong egy jelölt egyenes vonalon malmot alkot. Minden újonnan
   kialakított malom után egy ellenséges korongot kell levenni. Egyszerre
   több malom kialakításakor is egy korong vehető le.
3. Malomban álló korong védett, kivéve, ha az ellenfél összes korongja
   malomban áll: ilyenkor bármelyik levehető.
4. A lerakás befejezése után egy saját korong mozgatható vonal mentén egy
   közvetlenül szomszédos üres mezőre. Pontosan három korongnál bármely üres
   mezőre szabad ugrani.
5. Nyer, aki az ellenfelét két korongra fogyasztja vagy mozgásképtelenné teszi.
6. Háromszor ismétlődő állás ugyanazzal a soron következő játékossal, illetve
   ötven egymást követő, levétel nélküli egyéni mozgatási lépés döntetlent jelent.

Szabályforrások: [National Museum of Ireland](https://www.museum.ie/getmedia/9f42196f-152b-46c3-a2ed-ada63204d3db/NMI_PastTimes_NineMensMorris_Digital_FA.pdf),
[Morris játék kézikönyve](https://nine-mens-morris.net/manual.html).
Az állásismétlés és a lépésszám határa ennek a kiadásnak a rögzített változata.

## Forrás és fordítás

A fő forrás a `src/M.TEXT`, a játéklogika és rajzolás a `src/game.pas` fájlban
van; a `tools/generate_source.py` építi össze a bevált LOS alkalmazáskerettel.
A `G.TEXT`, `J.TEXT`, `D.TEXT`, `I.TEXT` a támogató LOS-egységek.
A `rules.py` független tesztmodell, a `test_rules.py` szabályteszteket és
teljes natív visszajátszási sorozatokat készít.

A LOS-keret eredete: [Alex LOS Minesweeper](https://github.com/alexthecat123/los_minesweeper).
A Malom játéklogikája, ikonjai és azonosítói saját fejlesztések.
ROM, LOS és SDK nem része a játékfloppynak. A kiadási próbák LisaEm-ben,
LOS 3.1 alatt, 1 MB RAM-mal sikeresen lezajlottak. Fizikai Lisa 2-n végzett
teszt még nincs dokumentálva. Az eredmények a [kiadási ellenőrzésben](VALIDATION.md)
és a validation mappában lévő JSON-jegyzőkönyvekben találhatók.


Letöltés: [Malom.dc42](https://github.com/julyus7/lisa-malom/releases/latest/download/Malom.dc42).
Újrafordítás: [BUILD.md](BUILD.md).
