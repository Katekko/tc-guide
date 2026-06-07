/// The kind of feedback a visitor is submitting.
///
/// The enum [key] is the stable wire value sent to Web3Forms and used as the
/// GitHub issue label; the human-readable label is resolved from
/// `AppLocalizations` in the presentation layer so it stays translated.
enum FeedbackCategory {
  /// Request for a brand-new guide or feature.
  feature,

  /// Report of something broken or incorrect.
  bug,

  /// Suggested correction to existing content.
  fix,

  /// A request or question about a specific guide.
  guide;

  /// Stable, locale-independent identifier (matches the enum name).
  String get key => name;
}
