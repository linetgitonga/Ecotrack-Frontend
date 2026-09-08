import 'package:ecotrack/core/utils/validators.dart';
import 'package:ecotrack/domain/value_objects/phone_number.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('normalizePhone', () {
    test('local 0-prefixed → +254', () {
      expect(Validators.normalizePhone('0712345678'), '+254712345678');
    });
    test('already E.164 passes through', () {
      expect(Validators.normalizePhone('+254712345678'), '+254712345678');
    });
    test('254-prefixed', () {
      expect(Validators.normalizePhone('254712345678'), '+254712345678');
    });
    test('strips spaces and dashes', () {
      expect(Validators.normalizePhone('+254 712-345 678'), '+254712345678');
    });
    test('garbage → null', () {
      expect(Validators.normalizePhone('abc'), isNull);
      expect(Validators.normalizePhone('+12'), isNull);
    });
  });

  group('phone validator', () {
    test('empty', () => expect(Validators.phone(''), isNotNull));
    test('valid', () => expect(Validators.phone('0712345678'), isNull));
    test('too short', () => expect(Validators.phone('0712'), isNotNull));
  });

  group('otp validator', () {
    test('6 digits ok', () => expect(Validators.otp('123456'), isNull));
    test('5 digits fails', () => expect(Validators.otp('12345'), isNotNull));
    test('letters fail', () => expect(Validators.otp('12345a'), isNotNull));
  });

  group('PhoneNumber value object', () {
    test('masked hides the middle', () {
      final p = PhoneNumber.tryParse('0712345678')!;
      expect(p.e164, '+254712345678');
      expect(p.masked, contains('•'));
      expect(p.masked, endsWith('678'));
    });
    test('national format', () {
      expect(PhoneNumber.tryParse('+254712345678')!.national, '0712 345 678');
    });
    test('invalid → null', () => expect(PhoneNumber.tryParse('nope'), isNull));
  });

  test('email validator', () {
    expect(Validators.email(''), isNull); // optional by default
    expect(Validators.email('', required: true), isNotNull);
    expect(Validators.email('a@b.co'), isNull);
    expect(Validators.email('a@b'), isNotNull);
  });
}
