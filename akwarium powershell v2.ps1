 $width = [Console]::WindowWidth - 1
 $height = [Console]::WindowHeight - 1
 $delay = 85

 $random = [System.Random]::new()
 $frame = 0

 $oldCursorVisible = [Console]::CursorVisible
 [Console]::CursorVisible = $false

 # Tworzenie 10 rybek
 $fish = @()
 $fishChars = @(">", "<", "s", "v", "F", "*", "L", "+", "f", "x", "^", "%", "H")

 for ($i = 0; $i -lt 10; $i++) {
$fish += [PSCustomObject]@{
    X        = $random.Next(2, $width - 1)
    Y        = $random.Next(3, $height - 9)
    DX       = if ($random.Next(0, 2) -eq 0) { -1 } else { 1 }
    Speed    = $random.Next(1, 5)
    Counter  = 0
    Char     = [char]$fishChars[$i]
    Energy   = 0
    EggTimer = 0
    Alive    = $true
}
 }

 $bubbles = @()
$eggs = @()

# Losowanie glonów tylko przy uruchomieniu programu
$weeds = @()
$weedCount = $random.Next(6, 16)

for ($i = 0; $i -lt $weedCount; $i++) {
$weeds += [PSCustomObject]@{
    X         = $random.Next(3, $width - 3)
    Height    = $random.Next(3, 7)
    MaxHeight = $random.Next(7, 12)
    Speed     = $random.Next(5, 15)
    Phase     = $random.NextDouble() * 6.28
    Age       = 0
    MaxAge    = $random.Next(1800, 3500)
    SeedTimer = $random.Next(100, 500)
}
}

# Żwirek
$gravelChars = @(".", ",", "'", ":", ";")

$gravelTop = New-Object char[] ($width + 1)
$gravelBottom = New-Object char[] ($width + 1)

for ($x = 1; $x -lt $width; $x++) {
    $gravelTop[$x] =
        [char]$gravelChars[$random.Next(0, $gravelChars.Count)]

    $gravelBottom[$x] =
        [char]$gravelChars[$random.Next(0, $gravelChars.Count)]
}

# Licznik powolnych zmian
$gravelTimer = 0
$gravelNextChange = $random.Next(10, 20)

 try {
     [Console]::Clear()

     while ($true) {
         $frame++

$lastWidth = $width
$lastHeight = $height

 $width = [Console]::WindowWidth - 1
 $height = [Console]::WindowHeight - 1

$newWidth = [Console]::WindowWidth - 1
$newHeight = [Console]::WindowHeight - 1


# Minimalny bezpieczny rozmiar
if ($newWidth -lt 20 -or $newHeight -lt 15) {
    [Console]::Clear()
    [Console]::SetCursorPosition(0, 0)
    [Console]::Write("Powieksz okno konsoli.")
    Start-Sleep -Milliseconds 200
    continue
}

# Reakcja na zmianę rozmiaru okna
if ($newWidth -ne $lastWidth -or $newHeight -ne $lastHeight) {
    $width = $newWidth
    $height = $newHeight

    $lastWidth = $width
    $lastHeight = $height

    # Tworzenie żwirku od nowa w nowym rozmiarze
    $gravelTop = New-Object char[] ($width + 1)
    $gravelBottom = New-Object char[] ($width + 1)

    for ($x = 1; $x -lt $width; $x++) {
        $gravelTop[$x] =
            [char]$gravelChars[$random.Next(0, $gravelChars.Count)]

        $gravelBottom[$x] =
            [char]$gravelChars[$random.Next(0, $gravelChars.Count)]
    }

    # Przesunięcie obiektów, które znalazły się poza nowym ekranem
    foreach ($f in $fish) {
        if ($f.X -ge $width) {
            $f.X = $width - 1
        }

        if ($f.Y -ge $height - 8) {
            $f.Y = $height - 9
        }
    }

    foreach ($weed in $weeds) {
        if ($weed.X -ge $width - 2) {
            $weed.X = $width - 3
        }
    }

    foreach ($egg in $eggs) {
        if ($egg.X -ge $width) {
            $egg.X = $width - 1
        }

        if ($egg.Y -ge $height - 3) {
            $egg.Y = $height - 3
        }
    }

    foreach ($bubble in $bubbles) {
        if ($bubble.X -ge $width) {
            $bubble.X = $width - 1
        }

        if ($bubble.Y -ge $height) {
            $bubble.Y = $height - 1
        }
    }

    [Console]::Clear()
}


# Starzenie się, rośnięcie i rozsiewanie glonów
foreach ($weed in $weeds) {
    $weed.Age++
    $weed.SeedTimer--

    # Glon rośnie powoli
    if ($weed.Age % 80 -eq 0 -and $weed.Height -lt $weed.MaxHeight) {
        $weed.Height++
    }

    # Glon rozsiewa nasiona
    if ($weed.SeedTimer -le 0 -and $weeds.Count -lt 25) {
        $newX = $weed.X + $random.Next(-5, 6)

        if ($newX -gt 3 -and $newX -lt ($width - 3)) {
            $weeds += [PSCustomObject]@{
                X         = $newX
                Height    = 2
                MaxHeight = $random.Next(6, 12)
                Speed     = $random.Next(5, 15)
                Phase     = $random.NextDouble() * 6.28
                Age       = 0
                MaxAge     = $random.Next(1800, 3500)
                SeedTimer = $random.Next(300, 800)
            }
        }

        $weed.SeedTimer = $random.Next(400, 900)
    }
}

# Usuwanie starych glonów
$weeds = @(
    $weeds | Where-Object {
        $_.Age -lt $_.MaxAge
    }
)


         # Tworzenie pustego ekranu
         $grid = @()

         for ($y = 0; $y -le $height; $y++) {
             $row = New-Object char[] ($width + 1)

             for ($x = 0; $x -le $width; $x++) {
                 $row[$x] = " "
             }

             $grid += ,$row
         }

# Ramka z samych znaków #
for ($x = 0; $x -le $width; $x++) {
    $grid[0][$x] = "#"
    $grid[$height][$x] = "#"
}

for ($y = 0; $y -le $height; $y++) {
    $grid[$y][0] = "#"
    $grid[$y][$width] = "#"
}

# Powolna zmiana żwirku
$gravelTimer++

if ($gravelTimer -ge $gravelNextChange) {
    $gravelTimer = 0

    # Zmienia się tylko 5-10 znaków naraz
    $changes = $random.Next(5, 11)

    for ($i = 0; $i -lt $changes; $i++) {
        $gravelX = $random.Next(1, $width)

        if ($random.Next(0, 2) -eq 0) {
            $gravelTop[$gravelX] =
                [char]$gravelChars[$random.Next(0, $gravelChars.Count)]
        }
        else {
            $gravelBottom[$gravelX] =
                [char]$gravelChars[$random.Next(0, $gravelChars.Count)]
        }
    }

    # Następna zmiana nastąpi po losowym czasie
    $gravelNextChange = $random.Next(10, 20)
}

# Rysowanie aktualnego żwirku
for ($x = 1; $x -lt $width; $x++) {
    $grid[$height - 1][$x] = $gravelTop[$x]
    $grid[$height - 2][$x] = $gravelBottom[$x]
}

$eggs = @(
    $eggs | Select-Object -Last 30
)

# Jajeczka opadające na dno
foreach ($egg in $eggs) {
    if ($egg.Y -lt $height - 3) {
        $egg.Y++
    }

    if ($egg.X -gt 1 -and $egg.X -lt $width) {
        $grid[$egg.Y][$egg.X] = "o"
    }
}

# Jajeczka na dnie
foreach ($egg in $eggs) {
    if ($egg.X -gt 1 -and $egg.X -lt $width) {
        $grid[$egg.Y][$egg.X] = "o"
    }
}


# Glony z losową pozycją, wysokością i prędkością
foreach ($weed in $weeds) {
    $sway = [int][Math]::Round(
        [Math]::Sin(($frame / $weed.Speed) + $weed.Phase) * 2
    )

    for ($part = 0; $part -lt $weed.Height; $part++) {
        $weedY = $height - 3 - $part

        # Górne części glona wychylają się mocniej
        $movement = [int]($sway * ($part / $weed.Height))
        $weedX = $weed.X + $movement

        if ($weedX -gt 1 -and
            $weedX -lt $width -and
            $weedY -gt 1 -and
            $weedY -lt $height) {

            if ($part % 3 -eq 0) {
                $grid[$weedY][$weedX] = "Y"
            }
            else {
                $grid[$weedY][$weedX] = "|"
            }
        }
    }
}


         # Ruch rybek
         foreach ($f in $fish) {
             $f.Counter++

             if ($f.Counter -ge $f.Speed) {
                 $f.Counter = 0
                 $f.X += $f.DX

                 # Odbicie od bocznych ścian
                 if ($f.X -le 1) {
                     $f.X = 1
                     $f.DX = 1
                 }

                 if ($f.X -ge ($width - 1)) {
                     $f.X = $width - 1
                     $f.DX = -1
                 }

                 # Delikatny ruch góra-dół
                 if ($random.Next(0, 8) -eq 0) {
                     $f.Y += $random.Next(-1, 2)
                 }

                 if ($f.Y -lt 2) {
                     $f.Y = 2
                 }

                 if ($f.Y -gt ($height - 5)) {
                     $f.Y = $height - 5
                 }
             }

             if ($f.X -gt 0 -and $f.X -lt $width -and
                 $f.Y -gt 0 -and $f.Y -lt $height) {
                 $grid[$f.Y][$f.X] = $f.Char
             }
         }

# Rybki zjadają glony, kiedy podpłyną blisko ich podstawy
foreach ($f in $fish) {
    if (-not $f.Alive) {
        continue
    }

    foreach ($weed in $weeds) {
        $distanceX = [Math]::Abs($f.X - $weed.X)

        $weedBottom = $height - 3
        $weedTop = $weedBottom - $weed.Height

        if ($distanceX -le 2 -and
            $f.Y -ge $weedTop -and
            $f.Y -le $weedBottom -and
            $random.Next(0, 20) -eq 0) {

            # Zjadanie fragmentu glona
            $weed.Height--
            $f.Energy += 10

            if ($weed.Height -le 0) {
                $weed.Age = $weed.MaxAge
            }
        }
    }
}

# Rybki mogą zjadać inne rybki
for ($a = 0; $a -lt $fish.Count; $a++) {
    if (-not $fish[$a].Alive) {
        continue
    }

    for ($b = 0; $b -lt $fish.Count; $b++) {
        if ($a -eq $b -or -not $fish[$b].Alive) {
            continue
        }

        $distanceX = [Math]::Abs($fish[$a].X - $fish[$b].X)
        $distanceY = [Math]::Abs($fish[$a].Y - $fish[$b].Y)

        if ($distanceX -le 1 -and
            $distanceY -le 1 -and
            $fish[$a].Energy -ge $fish[$b].Energy -and
            $random.Next(0, 25) -eq 0) {

            # Większa/najedzona rybka zjada drugą
            $fish[$b].Alive = $false
            $fish[$a].Energy += 35

            break
        }
    }
}

# Usuwanie zjedzonych rybek
$fish = @(
    $fish | Where-Object {
        $_.Alive
    }
)

# Najedzone rybki składają jajeczka na dnie
foreach ($f in $fish) {
    if ($f.Energy -ge 100) {
        $f.EggTimer--

        if ($f.EggTimer -le 0) {
            $eggs += [PSCustomObject]@{
                X = $f.X
                #Y = $height - 3
		Y = $f.Y
                Age = 0
            }

            $f.Energy = 0
            $f.EggTimer = $random.Next(300, 700)
        }
    }
}


# Wykluwanie jajeczek
$newFish = @()
$remainingEggs = @()

foreach ($egg in $eggs) {
    $egg.Age++

    # Jajeczko wykluwa się po około 10-25 sekundach
    if ($egg.Age -ge 400 -and ($fish.Count + $newFish.Count) -lt 25) {
        $newFish += [PSCustomObject]@{
            X        = $egg.X
            Y        = $height - 4
            DX       = if ($random.Next(0, 2) -eq 0) { -1 } else { 1 }
            Speed    = $random.Next(1, 5)
            Counter  = 0
            Char     = [char]$fishChars[$random.Next(0, $fishChars.Count)]
            Energy   = 0
            EggTimer = 0
            Alive    = $true
        }
    }
    else {
        # Jajeczko nadal pozostaje na dnie
        $remainingEggs += $egg
    }
}

# Usunięcie wyklutych jaj i dodanie nowych rybek
$eggs = $remainingEggs
$fish += $newFish


         # Tworzenie bąbelków
         if ($random.Next(0, 49) -eq 0) {
             $bubbles += [PSCustomObject]@{
                 X       = $random.Next(2, $width - 1)
                 Y       = $height - 4
                 Speed   = $random.Next(1, 4)
                 Counter = 0
                 Char    = [char]@("o", "O", "°")[$random.Next(0, 3)]
             }
         }

         # Ruch bąbelków
         foreach ($b in $bubbles) {
             $b.Counter++

             if ($b.Counter -ge $b.Speed) {
                 $b.Counter = 0
                 $b.Y--

                 if ($random.Next(0, 3) -eq 0) {
                     $b.X += $random.Next(-1, 2)
                 }
             }

             if ($b.X -gt 0 -and $b.X -lt $width -and
                 $b.Y -gt 0 -and $b.Y -lt $height) {
                 $grid[$b.Y][$b.X] = $b.Char
             }
         }

         # Usuwanie bąbelków, które wypłynęły
         $bubbles = @(
             $bubbles | Where-Object {
                 $_.Y -gt 1 -and
                 $_.X -gt 1 -and
                 $_.X -lt ($width - 1)
             }
         )

         # Zamiana tablicy znaków na jeden tekst
         $output = [System.Text.StringBuilder]::new()

         for ($y = 0; $y -le $height; $y++) {
             for ($x = 0; $x -le $width; $x++) {
                 [void]$output.Append($grid[$y][$x])
             }

             if ($y -lt $height) {
                 [void]$output.Append("`n")
             }
         }

         # Jedno rysowanie całej klatki
         [Console]::SetCursorPosition(0, 0)
         [Console]::Write($output.ToString())

         Start-Sleep -Milliseconds $delay
     }
 }
 finally {
     [Console]::CursorVisible = $oldCursorVisible
     [Console]::Clear()
     [Console]::SetCursorPosition(0, 0)
 }