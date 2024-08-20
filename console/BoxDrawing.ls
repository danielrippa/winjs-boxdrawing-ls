
  do ->

    { new-instance } = dependency 'primitive.Instance'
    { object-from-array, object-keys } = dependency 'native.Object'
    { type-error, Num } = dependency 'primitive.Type'

    {
      corner-kind, stroke-kind, weight-kind,
      any-kind, horizontal, vertical,
      single-stroke-code, quadruple-stroke-code, rounded-corner-code,
      vertical-bar-code, vertical-t-west-code, vertical-t-east-code
    } = dependency 'console.BoxDrawingImpl'

    unicode = -> try 0x2500 + Num it catch => type-error "Unicode"

    #

    corner-kind-names = object-keys corner-kind
    stroke-kind-names = object-keys stroke-kind
    weight-kind-names = object-keys weight-kind

    #

    CornerKind = (value) ->

      type-error "Invalid CornerKind value '#value'. Valid values are: #{ corner-kind-names.join ', ' }" \
        unless value in corner-kind-names

      value

    StrokeKind = (value) ->

      type-error "Invalid StrokeKind value '#value'. Valid values are: #{ stroke-kind-names.join ', ' }" \
        unless value in stroke-kind-names

      value

    WeightKind = (value) ->

      type-error "Invalid WeightKind value '#value'. Valid values are: #{ weight-kind-names.join ', ' }" \
        unless value in weight-kind-names

      value

    #

    new-stroke = ->

      stroke = stroke-kind.none
      weight = weight-kind.light

      new-instance do

        stroke:
          getter: -> stroke
          setter: -> stroke := StrokeKind it

        weight:
          getter: -> weight
          setter: -> weight := WeightKind it

    #

    sharp-corner-code = (char) ->

      { north, east, south, west } = char

      switch

        | any-kind south =>

          switch

            | any-kind east => se-corner-code char
            | any-kind west => sw-corner-code char

        | any-kind north =>

          switch

            | any-kind east => ne-corner-code char
            | any-kind west => nw-corner-code char

    #

    double-stroke-code = (char) ->

      match char

        | horizontal => horizontal-bar-code char
        | vertical   => vertical-bar-code char

        else

          switch char.corner
            | corner-kind.rounded => rounded-corner-code char
            | corner-kind.sharp   => sharp-corner-code   char

    #

    horizontal-t-code = (char) ->

      switch

        | any-kind north => horizontal-t-north-code char
        | any-kind south => horizontal-t-south-code char

    #

    vertical-t-code = (char) ->

      { east, west } = char

      switch

        | any-kind east => vertical-t-east-code char
        | any-kind west => vertical-t-west-code char

    #

    triple-stroke-code = (char) ->

      switch

        | horizontal char => horizontal-t-code char
        | vertical   char => vertical-t-code char

    #

    char-code = (char) ->

      stroke-count = 0

      for stroke-name in <[ north east south west ]>
        stroke = char[ stroke-name ]
        if any-kind stroke
          stroke-count++

      switch stroke-count

        | 0 => 0x20

        | 1 => unicode single-stroke-code char
        | 2 => unicode double-stroke-code char
        | 3 => unicode triple-stroke-code char
        | 4 => unicode quadruple-stroke-code char

    new-box-drawing-char = ->

      corner = corner-kind.sharp

      north = new-stroke!
      east =  new-stroke!
      south = new-stroke!
      west =  new-stroke!

      new-instance do

        corner:
          getter: -> corner
          setter: -> CornerKind it ; corner := it

        north: getter: -> north
        east:  getter: -> east
        south: getter: -> south
        west:  getter: -> west

        char-code: getter: -> char-code @

        to-string: member: -> String.from-char-code @char-code

    {
      corner-kind, stroke-kind, weight-kind,
      CornerKind, StrokeKind, WeightKind,
      new-box-drawing-char
    }
