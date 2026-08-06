/// Case-insensitive subsequence fuzzy match with a relevance score.
///
/// Returns `null` when [query] is not a subsequence of [target] — i.e. every
/// character of [query], in order, ignoring case, can be found somewhere in
/// [target] (not necessarily contiguous). Otherwise returns a score where
/// higher is a better match: contiguous runs and matches at [target]'s start
/// or right after a space score higher than scattered matches, and shorter
/// targets are preferred among otherwise-equal matches.
///
/// Used by [GlassCommandPalette] to rank commands against the search query;
/// exposed standalone since it has no dependency on the palette itself.
double? glassFuzzyScore(String query, String target) {
  if (query.isEmpty) return 0;
  if (target.isEmpty) return null;

  final q = query.toLowerCase();
  final t = target.toLowerCase();

  var qi = 0;
  var score = 0.0;
  var streak = 0;
  for (var ti = 0; ti < t.length && qi < q.length; ti++) {
    if (t[ti] != q[qi]) {
      streak = 0;
      continue;
    }
    streak++;
    // Contiguous runs score higher than scattered matches; word-boundary
    // matches (start of string, or right after a space) score higher still.
    var charScore = 1.0 + (streak - 1) * 0.5;
    if (ti == 0 || t[ti - 1] == ' ') charScore += 1.0;
    score += charScore;
    qi++;
  }

  if (qi < q.length) return null;
  // Small penalty for longer targets so tighter matches rank first among
  // otherwise comparable scores.
  return score - t.length * 0.01;
}
