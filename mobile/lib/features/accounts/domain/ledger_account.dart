/// An internal ledger identity. Labels are display snapshots, never lookup keys.
/// IDs are local identifiers, not provider account numbers or authorization.
class LedgerAccount {
  const LedgerAccount({required this.id, required this.label});
  final String id;
  final String label;
}
