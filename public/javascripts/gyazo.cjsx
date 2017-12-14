#
# React版 Gyazo FAQ
#

ReactDOM = require 'react-dom' # 最近これになったらしい
React =    require 'react'
createReactClass = require 'create-react-class'

require './gyazodata'

#
# URL引数の取得
#
params = {}
pairs = location.search.substring(1).split('&')
for pair in pairs
  kv = pair.split('=')
  params[kv[0]] = decodeURI(kv[1])

#
# 配列をランダムに並べかえる
#
shuffle = (array) ->
  n = array.length
  while n
    i = Math.floor(Math.random() * n--)
    [array[i], array[n]] = [array[n], array[i]]
  array
      
randomTimeout = null
waitTimeout = null

# App = React.createClass
App = createReactClass
  getInitialState: ->
    @waitAndRandom()
    query: params['q']
  #
  # ランダムにエントリを表示
  #
  randomDisplay: ->
    randomTimeout = setInterval =>
      keyword = keywords[Math.floor(Math.random() * keywords.length)]
      @update keyword
    , 4000

  waitAndRandom: ->
    clearTimeout randomTimeout
    clearTimeout waitTimeout
    waitTimeout = setTimeout =>
      @randomDisplay()
    , 10000
    
  update: (keyword) ->
    history.replaceState('','','?q='+keyword);
    @setState
      query: keyword

  render: ->
    <div onClick={@waitAndRandom}>
      <h1>Gyazo ヘルプセンター</h1>
      <blockquote>
        <form>
          <QueryInput update={@update} query={@state.query} wait={@waitAndRandom} />
          &nbsp;
          <input type="submit" value="検索" />
        </form>
      </blockquote>
      <Keywords update={@update} query={@state.query} />
      <p/>
      <hr width='95%' />
      <p/>
      <FAQList query={@state.query} />
    </div>

# Keywords = React.createClass
Keywords = createReactClass
  onClick: (e) ->
    @props.update e.target.id

  render: ->
    # 関連するキーワードを全部ハイライトする
    faqlist = []
    faqmatch = {}
    if @props.query && @props.query != ''
      for faq in faqs
        re = new RegExp(@props.query,'i')
        if faq.title.match re
          faqmatch[faq.url] = true
      for faq in faqs
        if faqmatch[faq.url]
          faqlist.push faq.title

    list = keywords.map (keyword) =>
      classname = "keyword"
      for faq in faqlist
        classname = "highlight" if faq.match(keyword)
      <span className={classname} onClick={@onClick} key={keyword} id={keyword}>{keyword}&nbsp;</span>
    <blockquote>{list}</blockquote>

# QueryInput = React.createClass
QueryInput = createReactClass
  onChange: (e) ->
    @props.wait()
    @props.update e.target.value

  render: ->
    <input type="text"
     autoComplete="off"
     value={@props.query}
     onChange={@onChange}
     name="q" />

# FAQList = React.createClass
FAQList = createReactClass
  render: ->
    #
    # queryにマッチするFAQエントリをすべてリストし、
    # その中のものをランダムに表示する
    #
    re = new RegExp @props.query,'i'
    faqlist = (faq for faq in faqs when faq.title.match(re))
    shuffle faqlist
    url_listed = {}
    faqlist = (faq for faq in faqlist when (
      s = url_listed[faq.url]
      url_listed[faq.url] = true
      !s
    ))

    fs = faqlist.map (faq) ->
      <li className='faq' key={faq.title}><a href={faq.url}>{faq.title}</a></li>
    <div>
      <ul>{fs}</ul>
    </div>

ReactDOM.render <App />
, document.getElementById 'faq'
