

String convertENotation(String input){
  String minus = '';

	if (input[0] == '+') input = input.substring(1);
  if (input[0] == '-'){
    minus = '-';
    input = input.substring(1);
  }

  if (input.contains('e+')){

    // example: '2.34e+3' => '2340'
    if (input.contains('.')){
      String value = input.substring(input.indexOf('.')+1, input.indexOf('e'));
      input = 
        input.substring(0, input.indexOf('.')) 
        + value
        + ('0' * (int.parse(input.substring(input.indexOf('+')+1)) - value.length));

    // example: '234e+4' => '2340000'
    } else {
      input = 
        input.substring(0, input.indexOf('e'))
        + ('0' * int.parse(input.substring(input.indexOf('+')+1)));
    }

  } else if (input.contains('e-')){

    // example: '2.34e-4' => '0.000234'
    if (input.contains('.')){
      String value = input.substring(0, input.indexOf('.'));
      input = 
        '0.'
        + ('0' * (int.parse(input.substring(input.indexOf('-')+1)) - value.length))
        + value
        + input.substring(input.indexOf('.')+1, input.indexOf('e'));

    // example: '234e-4' => '0.0234'
    } else {
      String value = input.substring(0, input.indexOf('e'));
      input = 
        '0.'
        + ('0' * (int.parse(input.substring(input.indexOf('-')+1)) - value.length))
        + value;
    }

  } else if (input.contains('e')){

    // example: '2.34e4' => '23400'
    if (input.contains('.')){
      String value = input.substring(input.indexOf('.')+1, input.indexOf('e'));
      input = 
        input.substring(0, input.indexOf('.')) 
        + value
        + ('0' * (int.parse(input.substring(input.indexOf('e')+1)) - value.length));

    // example: '234e4' => '2340000'
    } else {
      input = 
        input.substring(0, input.indexOf('e'))
        + ('0' * int.parse(input.substring(input.indexOf('e')+1)));
    }
  }

  input = minus + input;

  return input;
}
