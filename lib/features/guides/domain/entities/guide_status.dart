/// The review/freshness state of a guide page, surfaced as a badge on the
/// guide index so readers can judge how trustworthy a page's content is.
///
/// Pages start as [draft] and are promoted as they are reviewed against the
/// current game state.
enum GuideStatus {
  /// Copied or summarized from community sources, not fully reviewed.
  draft,

  /// Likely useful but may be outdated or incomplete.
  needsReview,

  /// Reviewed against the current game state.
  current,

  /// Kept for history, not recommended as current advice.
  outdated,
}
