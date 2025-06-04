module Editor::BlockNesting
  #
  # https://developer.mozilla.org/en-US/docs/Web/HTML/Reference/Elements
  AVAILABLE_BLOCKS = {
    a:            { type: "inline",       not_children: %w[a], children: %w[] },
    abbr:         { type: "inline",       not_children: %w[abbr], children: %w[] },
    address:      { type: "section",      not_children: %w[address], children: %w[] },
    area:         { type: "multimedia",   not_children: %w[area], children: %w[] },
    article:      { type: "section",      not_children: %w[], children: %w[] },
    aside:        { type: "section",      not_children: %w[aside], children: %w[] },
    audio:        { type: "multimedia",   not_children: %w[audio], children: %w[] },
    b:            { type: "inline",       not_children: %w[b], children: %w[] },
    base:         { type: "meta",         not_children: %w[base], children: %w[] },
    bdi:          { type: "inline",       not_children: %w[bdi], children: %w[] },
    bdo:          { type: "inline",       not_children: %w[bdo], children: %w[] },
    blockquote:   { type: "content",      not_children: %w[blockquote], children: %w[] },
    body:         { type: "section",      not_children: %w[body], children: %w[] },
    br:           { type: "inline",       not_children: %w[br], children: %w[] },
    button:       { type: "form",         not_children: %w[button], children: %w[] },
    canvas:       { type: "script",       not_children: %w[canvas], children: %w[] },
    caption:      { type: "table",        not_children: %w[caption], children: %w[] },
    cite:         { type: "inline",       not_children: %w[cite], children: %w[] },
    code:         { type: "inline",       not_children: %w[code], children: %w[] },
    col:          { type: "table",        not_children: %w[col], children: %w[] },
    colgroup:     { type: "table",        not_children: %w[colgroup], children: %w[] },
    data:         { type: "inline",       not_children: %w[data], children: %w[] },
    datalist:     { type: "form",         not_children: %w[datalist], children: %w[] },
    dd:           { type: "content",      not_children: %w[dd], children: %w[] },
    del:          { type: "demarc",       not_children: %w[del], children: %w[] },
    details:      { type: "interactive",  not_children: %w[details], children: %w[] },
    dfn:          { type: "inline",       not_children: %w[dfn], children: %w[] },
    dialog:       { type: "interactive",  not_children: %w[dialog], children: %w[] },
    div:          { type: "content",      not_children: %w[], children: %w[] },
    dl:           { type: "content",      not_children: %w[dl], children: %w[] },
    dt:           { type: "content",      not_children: %w[dt], children: %w[] },
    em:           { type: "inline",       not_children: %w[em], children: %w[] },
    embed:        { type: "embedded",     not_children: %w[embed], children: %w[] },
    fieldset:     { type: "form",         not_children: %w[fieldset], children: %w[] },
    figcaption:   { type: "content",      not_children: %w[figcaption], children: %w[] },
    figure:       { type: "content",      not_children: %w[figure], children: %w[] },
    footer:       { type: "section",      not_children: %w[footer], children: %w[] },
    form:         { type: "form",         not_children: %w[form], children: %w[] },
    h1:           { type: "section",      not_children: %w[h1 h2 h3 h4 h5 h6], children: %w[] },
    h2:           { type: "section",      not_children: %w[h1 h2 h3 h4 h5 h6], children: %w[] },
    h3:           { type: "section",      not_children: %w[h1 h2 h3 h4 h5 h6], children: %w[] },
    h4:           { type: "section",      not_children: %w[h1 h2 h3 h4 h5 h6], children: %w[] },
    h5:           { type: "section",      not_children: %w[h1 h2 h3 h4 h5 h6], children: %w[] },
    h6:           { type: "section",      not_children: %w[h1 h2 h3 h4 h5 h6], children: %w[] },
    head:         { type: "meta",         not_children: %w[head], children: %w[] },
    header:       { type: "section",      not_children: %w[header], children: %w[] },
    hgroup:       { type: "section",      not_children: %w[hgroup], children: %w[] },
    hr:           { type: "content",      not_children: %w[hr], children: %w[] },
    html:         { type: "main",         not_children: %w[html], children: %w[] },
    i:            { type: "inline",       not_children: %w[i], children: %w[] },
    iframe:       { type: "embedded",     not_children: %w[iframe], children: %w[] },
    img:          { type: "multimedia",   not_children: %w[img], children: %w[] },
    input:        { type: "form",         not_children: %w[input], children: %w[] },
    ins:          { type: "demarc",       not_children: %w[ins], children: %w[] },
    kbd:          { type: "inline",       not_children: %w[kbd], children: %w[] },
    label:        { type: "form",         not_children: %w[label], children: %w[] },
    legend:       { type: "form",         not_children: %w[legend], children: %w[] },
    li:           { type: "content",      not_children: %w[li], children: %w[] },
    link:         { type: "meta",         not_children: %w[link], children: %w[] },
    main:         { type: "section",      not_children: %w[main], children: %w[] },
    map:          { type: "multimedia",   not_children: %w[map], children: %w[] },
    mark:         { type: "inline",       not_children: %w[mark], children: %w[] },
    math:         { type: "svg_math",     not_children: %w[math], children: %w[] },
    menu:         { type: "content",      not_children: %w[menu], children: %w[] },
    meta:         { type: "meta",         not_children: %w[meta], children: %w[] },
    meter:        { type: "form",         not_children: %w[meter], children: %w[] },
    nav:          { type: "section",      not_children: %w[nav], children: %w[] },
    noscript:     { type: "script",       not_children: %w[noscript], children: %w[] },
    object:       { type: "embedded",     not_children: %w[object], children: %w[] },
    ol:           { type: "content",      not_children: %w[ol], children: %w[li] },
    optgroup:     { type: "form",         not_children: %w[optgroup], children: %w[] },
    option:       { type: "form",         not_children: %w[option], children: %w[] },
    output:       { type: "form",         not_children: %w[output], children: %w[] },
    p:            { type: "content",      not_children: %w[p], children: %w[] },
    picture:      { type: "embedded",     not_children: %w[picture], children: %w[] },
    pre:          { type: "content",      not_children: %w[pre], children: %w[] },
    progress:     { type: "form",         not_children: %w[progress], children: %w[] },
    q:            { type: "inline",       not_children: %w[q], children: %w[] },
    rp:           { type: "inline",       not_children: %w[rp], children: %w[] },
    rt:           { type: "inline",       not_children: %w[rt], children: %w[] },
    ruby:         { type: "inline",       not_children: %w[ruby], children: %w[] },
    s:            { type: "inline",       not_children: %w[s], children: %w[] },
    samp:         { type: "inline",       not_children: %w[samp], children: %w[] },
    script:       { type: "inline",       not_children: %w[script], children: %w[] },
    search:       { type: "section",      not_children: %w[search], children: %w[] },
    section:      { type: "section",      not_children: %w[section], children: %w[] },
    select:       { type: "form",         not_children: %w[select], children: %w[] },
    slot:         { type: "web",          not_children: %w[slot], children: %w[] },
    small:        { type: "inline",       not_children: %w[small], children: %w[] },
    source:       { type: "embedded",     not_children: %w[source], children: %w[] },
    span:         { type: "inline",       not_children: %w[span], children: %w[] },
    strong:       { type: "inline",       not_children: %w[strong], children: %w[] },
    style:        { type: "meta",         not_children: %w[style], children: %w[] },
    sub:          { type: "inline",       not_children: %w[sub], children: %w[] },
    summary:      { type: "interactive",  not_children: %w[summary], children: %w[] },
    sup:          { type: "inline",       not_children: %w[sup], children: %w[] },
    svg:          { type: "svg_math",     not_children: %w[svg], children: %w[] },
    table:        { type: "table",        not_children: %w[table], children: %w[thead tbody tfoot tr] },
    tbody:        { type: "table",        not_children: %w[tbody], children: %w[tr th] },
    td:           { type: "table",        not_children: %w[td], children: %w[] },
    template:     { type: "web",          not_children: %w[template], children: %w[] },
    textarea:     { type: "form",         not_children: %w[textarea], children: %w[] },
    tfoot:        { type: "table",        not_children: %w[tfoot], children: %w[tr] },
    th:           { type: "table",        not_children: %w[th], children: %w[] },
    thead:        { type: "table",        not_children: %w[thead], children: %w[tr] },
    time:         { type: "inline",       not_children: %w[time], children: %w[] },
    title:        { type: "meta",         not_children: %w[title], children: %w[] },
    tr:           { type: "table",        not_children: %w[tr], children: %w[th td] },
    track:        { type: "multimedia",   not_children: %w[track], children: %w[] },
    u:            { type: "inline",       not_children: %w[u], children: %w[] },
    ul:           { type: "content",      not_children: %w[ul], children: %w[li] },
    var:          { type: "inline",       not_children: %w[var], children: %w[] },
    video:        { type: "multimedia",   not_children: %w[video], children: %w[] },
    wbr:          { type: "inline",       not_children: %w[wbr], children: %w[] }

    # "div" => %w[div span p h1 h2 ul table image],
    # "p"   => %w[span br],
    # "h1"  => %w[span br],
    # "h2"  => %w[span br],
    # "h3"  => %w[span br],
    # "h4"  => %w[span br],
    # "h5"  => %w[span br],
    # "h6"  => %w[span br],
    # "ul"  => %w[li],
    # "ol"  => %w[li],
    # "table" => %w[thead tbody tr],
    # "thead" => %w[tr],
    # "tbody" => %w[tr],
    # "tr" => %w[td th],
    # "td" => %w[div p span],
    # "span" => []
  }

  def self.allowed_block?(block_type)
    AVAILABLE_BLOCKS.key?(block_type)
  end

  def self.block_list
    AVAILABLE_BLOCKS.keys
  end

  # Get the allowed child block types for a given parent block type
  def self.allowed_children(parent_type)
    AVAILABLE_BLOCKS.fetch(parent_type, [])
  end

  # Check if a block type is allowed as a child of another block type
  def self.allowed_parent?(block_type)
    AVAILABLE_BLOCKS.key?(block_type)
  end

  # Check if a child block type is allowed under a parent block type
  # Returns true if the parent is nil (root) or if the child type is allowed under the parent
  def self.allowed_child?(parent_type, child_type)
    return true if parent_type.blank? # root
    h = AVAILABLE_BLOCKS.fetch(parent_type, {})
    h[:children].include?(child_type) || h[:not_children].exclude?(child_type)
  end
end
