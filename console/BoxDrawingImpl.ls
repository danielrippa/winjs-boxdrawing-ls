
  do ->

    { object-from-array } = dependency 'native.Object'

    ck = corner-kind = object-from-array <[ sharp rounded ]>
    sk = stroke-kind = object-from-array <[ none single double doubledash tripledash quadrupledash ]>
    wk = weight-kind = object-from-array <[ light bold ]>

    rounded = (.corner is ck.rounded)
    sharp   = (.corner is ck.sharp)

    none = (.stroke is sk.none)
    any-kind = -> not none it

    single = (.stroke is sk.single)
    double = (.stroke is sk.double)
    ddash  = (.stroke is sk.doubledash)
    tdash  = (.stroke is sk.tripledash)
    qdash  = (.stroke is sk.quadrupledash)

    single-or-double = ({ stroke }, single-value, double-value) ->

      switch stroke
        | sk.single => single-value
        | sk.double => double-value

    light = (.weight is wk.light)
    bold  = (.weight is wk.bold)

    light-or-bold = ({ weight }, light-value, bold-value) ->

      switch weight
        | wk.light => light-value
        | wk.bold  => bold-value

    are = (stroke-fn, stroke1, stroke2) -> stroke-fn stroke1 and stroke-fn stroke2

    horizontal = (char) -> are any-kind, char.west,  char.east
    vertical   = (char) -> are any-kind, char.north, char.south

    #

    quadruple-stroke-code = ({ north, east, south, west }) ->

      switch

        | are single, north, south and are single, east, west =>

          switch

            | are light, north, south and are light, east, west => 0x3c
            | are bold,  north, south and are bold,  east, west => 0x4b

            else

              bold-count = 0

              for stroke in [ north, east, south, west ]

                if bold stroke
                  bold-count++

              switch bold-count

                | 1 =>

                  switch

                    | bold north => 0x40
                    | bold east  => 0x3e
                    | bold south => 0x41
                    | bold west  => 0x3d

                | 2 =>

                  switch

                    | are bold, north, south => 0x42
                    | are bold, east,  west  => 0x3f

                    | bold north =>

                      switch

                        | bold east => 0x43
                        | bold west => 0x44

                    | bold south =>

                      switch

                        | bold east => 0x45
                        | bold west => 0x46

                  | 3 =>

                    switch

                      | light north => 0x48
                      | light east  => 0x49
                      | light south => 0x47
                      | light west  => 0x4a

        | are double, north, south and are double, east, west => 0x6c
        | are double, north, south => 0x6b
        | are double, east,  west  => 0x6a

        else 0x3c

    #

    vertical-t-west-code = ({ north, south, west }) ->

      switch

        | are single, north, south and double west => 0x61
        | are double, north, south => single-or-double west, 0x62, 0x63
        | are light,  north, south => light-or-bold west, 0x24, 0x25
        | are bold,   north, south => light-or-bold west, 0x28, 0x2b

        else

          switch

            | light west =>

              switch

                | bold  north and light south => 0x26
                | light north and bold  south => 0x27

            | bold west =>

              switch

                | bold  north and light south => 0x29
                | light north and bold  south => 0x2a

    #

    vertical-t-east-code = ({ north, east, south }) ->

      switch

        | are single, north, south and double east => 0x5e
        | are double, north, south => single-or-double east, 0x5f, 0x60
        | are ligth,  north, south => light-or-bold    east, 0x1c, 0x1d
        | are bold,   north, south => light-or-bold    east, 0x20, 0x23

        else

          switch

            | light east =>

              switch

                | bold north and light south => 0x1e
                | light north and bold south => 0x1f

            | bold east =>

              switch

                | bold  north and light south => 0x21
                | light north and bold  south => 0x22

    #

    horizontal-t-south-code = ({ south, west, east }) ->

      switch

        | are double, west, east =>

          switch

            | double south => 0x66
            else 0x64

        | double south => 0x65

        else

          bold-count = 0
          for stroke in [ south, west, east ]

            if bold stroke
              bold-count++

          switch bold-count

            | 0 => 0x2c
            | 1 =>

              switch

                | bold south => 0x30
                | bold east  => 0x2e
                | bold west  => 0x2d

            | 2 =>

              switch

                | light south => 0x2f
                | light east  => 0x31
                | light west  => 0x32

            | 3 => 0x33

    #

    horizontal-t-north-code = ({ north, west, east }) ->

      switch

        | are double, west, east =>

          switch

            | double north => 0x69
            else 0x67

        | double north => 0x68

        else

          bold-count = 0

          for stroke in [ north, east, west ]

            if bold stroke

              bold-count++

          switch bold-count

            | 0 => 0x34
            | 1 =>

              switch

                | bold north => 0x38
                | bold east  => 0x35
                | bold west  => 0x36

            | 2 =>

              switch

                | light north => 0x37
                | light east  => 0x39
                | light west  => 0x3a

            | 3 => 0x3b

    #

    horizontal-bar-code = ({ west, east }) ->

      switch

        | qdash west or qdash east =>

          switch

            | bold west or bold east => 0x09
            else 0x08

        | tdash west or tdash east =>

          switch

            | bold west or bold east => 0x05
            else 0x04

        | ddash west or ddash east =>

          match west, east

            | bold, bold => 0x4d
            else 0x4c

        | double west or double east => 0x50

        else

          match west, east

            | bold,  bold  => 0x01
            | light, light => 0x00
            | bold,  light => 0x7e
            | light, bold  => 0x7c

    #

    vertical-bar-code = ({ north, south }) ->

      switch

        | qdash north or qdash south =>

          switch

            | bold north or bold south => 0x0b
            else 0x0a

        | tdash north or tdash south =>

          switch

            | bold north or bold south => 0x07
            else 0x06

        | ddash north or ddash south =>

          match north, south

            | bold, bold => 0x4f
            else 0x4e

        else

          match north, south

            | bold, bold => 0x03
            | light, light => 0x02
            | bold, light => 0x7f
            | light, bold => 0x7d

    #

    rounded-corner-code = ({ north, east, south, west }) ->

      switch

        | any-kind north =>

          switch

            | any-kind east => 0x70
            | any-kind west => 0x6f

        | any-kind south =>

          switch

            | any-kind east => 0x6d
            | any-kind west => 0x6e

    #

    se-corner-code = ({ south, east }) ->

      switch

        | are double, south, east => 0x54
        | are single, south, east =>

          switch

            | are light, south, east => 0x0c
            | are bold,  south, east => 0x0f

            else

              switch

                | bold south and light east => 0x0e
                | light south and bold east => 0x0d

        else

          switch

            | double south => 0x53
            | double east  => 0x52

    #

    sw-corner-code = ({ south, west }) ->

      switch

        | are double, south, west => 0x57
        | are single, south, west =>

          switch

            | are light, south, west => 0x10
            | are bold,  south, west => 0x13

            else

              switch

                | bold  south and light west => 0x12
                | light south and bold west  => 0x11

        else

          switch

            | double south => 0x56
            | double west  => 0x55

    #

    ne-corner-code = ({ north, east }) ->

      switch

        | are double, north, east => 0x5a
        | are single, north, east =>

          switch

            | are light, north, east => 0x14
            | are bold,  north, east => 0x17

            else

              switch

                | bold  north and light east => 0x16
                | light north and bold  east => 0x15

        else

          switch

            | double north => 0x59
            | double east  => 0x58

    #

    nw-corner-code = ({ north, west }) ->

      switch

        | are double, north, west => 0x5d
        | are single, north, west =>

          switch

            | are light, north, west => 0x18
            | are bold,  north, west => 0x1b

            else

              switch

                | bold  north and light west => 0x1a
                | light north and bold  west => 0x19

        else

          switch

            | double north => 0x5c
            | double west  => 0x5b

    #

    single-stroke-code = ({ north, east, south, west }) ->

      switch

        | any-kind north => light-or-bold north, 0x75, 0x79
        | any-kind east  => light-or-bold east,  0x76, 0x7a
        | any-kind south => light-or-bold south, 0x77, 0x7b
        | any-kind west  => light-or-bold west,  0x78, 0x74

    {
      corner-kind, stroke-kind, weight-kind,
      any-kind,
      horizontal, vertical,
      single-stroke-code, quadruple-stroke-code, rounded-corner-code,
      vertical-bar-code, vertical-t-west-code, vertical-t-east-code
    }