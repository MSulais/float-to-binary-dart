
// ## FLOATING POINT NUMBER ##

// 32-bit floating point number 
// 0    00101100 00101001110001101000100 (example)
// sign exponent -------mantissa--------
//
// sign     = ( 1 bit ) 0
// exponent = ( 8 bits) 00101100
// mantissa = (23 bits) 00101001110001101000100
// 
// info: https://en.wikipedia.org/wiki/Single-precision_floating-point_format

// 64-bit floating point number 
// 0    00101100001 0100111000110100010000010110000101001110001101000100 (example)
// sign -exponent-- ----------------------mantissa----------------------
// 
// sign     = ( 1 bit ) 0
// exponent = (11 bits) 00101100001
// mantissa = (52 bits) 0100111000110100010000010110000101001110001101000100
// 
// info: https://en.wikipedia.org/wiki/Double-precision_floating-point_format

import 'dart:math' as math;
import 'e_notation.dart';


String binaryToFloat(String input, int bit){  
  bool isMinus = input[0] == '-';
  
  if (input[0] == '+' || input[0] == '-') input = input.substring(1);
  if (input.length > bit) input = input.substring(0, bit);
  if (input.length < bit) input = ('0' * (bit - input.length)) + input;
  if (isMinus) input = '1' + input.substring(1);

  String carry    = '0';
  String sign     = input.substring(0, 1);
  String exponent = input.substring(1, bit == 32? 9 : 12);
  String mantissa = input.substring(bit == 32? 9 : 12);

  // convert mantissa from bits to real numbers
  for (int i = 1; i <= mantissa.length; i++) { if (mantissa.substring(i - 1, i) == '1') {
    carry = (double.parse(carry) + math.pow(2, -i)).toString();
  } }

  // mantissa in real numbers (base10)
  mantissa = carry;
  exponent = BigInt.parse(exponent, radix: 2).toString();
  
  if (exponent == '0'){
    // denormalized 
    input = 
      (math.pow(-1, int.parse(sign))
      * math.pow(2, (bit == 32? -126 : -1022))
      * double.parse(mantissa)).toString()
    ;
      
  } else {
    input = 
      (math.pow(-1, int.parse(sign)) 
      * math.pow(2, int.parse(exponent)-(bit == 32? 127 : 1023)) 
      * (1 + double.parse(mantissa))).toString()  
    ;
  }
  return input;
}




String floatToBinary(String input, int bit){
  input = convertENotation(input);
  if (!input.contains('.')) input += '.0';

  String carry    = '';
  String sign     = input.contains('-')? '1' : '0';
  String exponent = '';
  String mantissa = '';
    
  // example: [ input="12.3" ] => [ number="12" decimal="0.3" ] 
  String number  = BigInt.parse(input.substring(0, input.indexOf('.'))).toRadixString(2);
  String decimal = '0' + input.substring(input.indexOf('.'));

  int n = 0; 
  int cache = 0;
   
   // convert [ float ] from real number to binary 
  while (n <= 150){
    carry = (double.parse(decimal) * 2).toString();
    carry = convertENotation(carry);

    if (carry == '0') carry += '.0';

    decimal = '0' + carry.substring(carry.indexOf('.'));
    mantissa += carry.substring(0, 1);

    if (mantissa.contains('1')) {
      ++n;
    } else {
      cache++;
    }
    
    if (cache == 2000) break; // maximum loop times
  }

  // combine all together
  mantissa = number + '.' + mantissa;

  int indexDot = mantissa.indexOf('.');
  int indexOne = mantissa.indexOf('1');
  int substractForExp = indexDot < indexOne
    ? indexDot - indexOne 
    : indexDot - (indexOne +1)
  ;

  bool more = false;
  bool less = false;

  if (indexOne != -1){
    exponent = (BigInt.from(substractForExp) + BigInt.from((bit == 32? 127 : 1023))).toString();
    if (int.parse(exponent) > (bit == 32? 255 : 4095)) {
      more = true;
      exponent = '255';
    } else if (int.parse(exponent) < 0) {
      less = true;
      exponent = '0';
    }
    exponent = BigInt.parse(exponent).toRadixString(2);

  } else {
    exponent = '0';
  }

  // example: [ exponent="101" ] => [ exponent="00000101"(Float32) exponent="00000000101"(Float64) ]
  if (exponent.length < (bit == 32? 8 : 11)) {
    exponent = ('0' * ((bit == 32? 8 : 11) - exponent.length)) + exponent;
  }

  if (indexOne == -1) {
    mantissa = mantissa.substring(mantissa.indexOf('.') + 1);
  } else {

    if (indexDot < indexOne) {
      if (less) {
        mantissa = mantissa.substring(mantissa.indexOf('.') + (bit == 32? 127 : 1023));
      } else {
        mantissa = mantissa.substring(mantissa.indexOf('1') + 1);
      }
    }

    else if (indexDot > indexOne) {
      if (more) {
        mantissa = mantissa.substring(
          mantissa.indexOf('.') - (bit == 32? 127 : 1023), 
          mantissa.indexOf('.') + 1
        );
      } else {
        mantissa = mantissa.substring(
            mantissa.indexOf('1') + 1, 
            mantissa.indexOf('.')
          ) 
          + mantissa.substring(mantissa.indexOf('.') + 1);
      }
    }
  }

  String output = sign + exponent + mantissa;
  output = output.substring(0, bit == 32? 32 : 64);

  return output;
  // NOTES: 
  //   Sometimes, the last 1-8 bits in the final result lose some bit precision.
  //   Even if it only changes the precision a little to the actual number (base10), 
  //   it's still wrong. I'm still looking for a way to get the correct result.
}
