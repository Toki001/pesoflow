/// Conservative English amount-in-words fallback for labeled paper invoices.
/// Unknown words or incomplete scales are rejected rather than guessed.
int? receiptAmountInWords(String text) {
  final tokens = text
      .toLowerCase()
      .replaceAll('-', ' ')
      .replaceAll(RegExp(r'[, .]'), ' ')
      .split(RegExp(r'\s+'))
      .where((w) => w.isNotEmpty)
      .toList();
  const values = <String, int>{
    'zero': 0,
    'one': 1,
    'two': 2,
    'three': 3,
    'four': 4,
    'five': 5,
    'six': 6,
    'seven': 7,
    'eight': 8,
    'nine': 9,
    'ten': 10,
    'eleven': 11,
    'twelve': 12,
    'thirteen': 13,
    'fourteen': 14,
    'fifteen': 15,
    'sixteen': 16,
    'seventeen': 17,
    'eighteen': 18,
    'nineteen': 19,
    'twenty': 20,
    'thirty': 30,
    'forty': 40,
    'fifty': 50,
    'sixty': 60,
    'seventy': 70,
    'eighty': 80,
    'ninety': 90,
  };
  var total = 0, group = 0, previous = -1;
  var seen = false;
  for (final word in tokens) {
    if (['and', 'peso', 'pesos', 'only'].contains(word)) continue;
    final value = values[word];
    if (value != null) {
      if (previous >= 0 &&
          !(previous >= 20 && previous % 10 == 0 && value > 0 && value < 10)) {
        return null;
      }
      group += value;
      previous = value;
      seen = true;
    } else if (word == 'hundred') {
      if (group < 1 || group > 9) return null;
      group *= 100;
      previous = -1;
    } else if (word == 'thousand' || word == 'million') {
      if (group == 0) return null;
      total += group * (word == 'thousand' ? 1000 : 1000000);
      group = 0;
      previous = -1;
    } else {
      return null;
    }
  }
  final result = (total + group) * 100;
  return seen && result > 0 && result <= 99999999999 ? result : null;
}
