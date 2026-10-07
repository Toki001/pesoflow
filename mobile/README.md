# PesoFlow mobile

Native Flutter translation of the approved Stitch design, using persisted local
financial records. Run `flutter pub get` then `flutter run` on Android or iOS.
No backend or credentials are needed for manual tracking.

Startup opens the encrypted Drift workspace before rendering financial screens.
A fresh install contains no accounts, transactions or budgets. Finish the
introduction, open Accounts from Home's balance card, add a manual account, then
use Add for expenses, income and transfers. Budgets and Analytics update from the
same saved ledger. Storage failures retain saved data and offer retry.

```sh
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
flutter build apk --debug
flutter build ios --simulator --debug
```

See [production readiness](../docs/production-readiness.md) and
[test infrastructure](test/README.md). OCR, providers, server authentication,
cloud sync and release packaging remain separate tasks.
