PATCH NOTES
================================================================================

Da združiš vnose različnih komisij naj vsak član komisije:

1. naredi kopijo seznama v katerega bo vnašal:

```
./2023_Seznam_Planinca.csv
./2023_Seznam_Planinca_jure.csv
```

2. nato naj vnaša podatke v svojo kopijo, originalno datoteko pa
naj pusti nedotaknjeno...

3. po končanih vnosih naj zabeleži spremembe v svoj file. Spremembe naj
bodo zabeležene brez kontekstnih vrstic:

```
  diff -unified=0 2023_Seznam_Planinca.csv 2023_Seznam_Planinca_jure.csv > jure.patch
```

4. Na koncu se zberejo posamezne datoteke vseh sprememb in se jih uveljavi na originalnem filu:

```
  patch -p1 2023_Seznam_Planinca.csv < jure.patch
  patch -p2 2023_Seznam_Planinca.csv < mija.patch
  patch -p3 2023_Seznam_Planinca.csv < ančka.patch
```


