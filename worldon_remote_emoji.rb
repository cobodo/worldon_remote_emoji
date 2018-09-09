Plugin.create(:worldon_remote_emoji) do
  re = %r<:(\w+)@([0-9A-Za-z\.-]+):>.freeze
  emoji_map = TimeLimitedStorage.new(String, Hash) # domain -> shortcode -> Plugin::Worldon::Emoji

  filter_worldon_remote_emoji_cache do |_|
    [emoji_map]
  end

  # Scoreフィルタ
  filter_score_filter do |target_model, note, yielder|
    next [target_model, note, yielder] if target_model == note

    # 含まれるか判定
    text = note.description
    m = re.match(text)
    next [target_model, note, yielder] unless m

    # Score候補を作成していく
    score = Array.new
    if m.pre_match && m.pre_match.size > 0
      # emojiより前のテキストを投入
      score << Diva::Model(:score_text).new(description: m.pre_match)
    end

    domain = m[2]
    shortcode = m[1]
    if emoji_map[domain].nil? || emoji_map[domain][shortcode].nil?
      # キャッシュに無いのでリモートから取得
      resp = Plugin::Worldon::API.call(:get, domain, '/api/v1/custom_emojis')
      next [target_model, note, yielder] if (!resp || !resp.value)

      # レスポンスからEmojiオブジェクトを作っておく
      emoji_map[domain] = Hash.new
      resp.value.each do |h|
        emoji = Plugin::Worldon::Emoji.new(h)
        emoji_map[domain][h[:shortcode]] = emoji
      end
    end
    next [target_model, note, yielder] if (emoji_map[domain].nil? || emoji_map[domain][shortcode].nil?)

    # emojiを投入
    score << emoji_map[domain][shortcode]

    if m.post_match && m.post_match.size > 0
      # emojiより後のテキストを投入（まだemojiを含んでいる可能性があるが、再帰的に探索されるので無視してよい）
      score << Diva::Model(:score_text).new(description: m.post_match)
    end

    # Score候補を提出
    yielder << score

    [target_model, note, yielder]
  end
end
