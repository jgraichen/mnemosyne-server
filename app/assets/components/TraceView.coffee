import {
  Component,
  createElement as $
} from './core'

import IconStar from 'react-icons/fa/star'
import IconStarOff from 'react-icons/fa/star-o'

import URI from 'urijs'
import 'urijs/src/URITemplate'

import PropTypes from 'prop-types'

import './TraceView.sass'

import { TraceInfo } from './TraceInfo'
import { TraceMeta } from './TraceMeta'
import { TraceGraph } from './TraceGraph'

makeRoutes = (routes) ->
  helpers = Object.create(null)

  for key in Object.keys(routes)
    helpers[key] = do(uri = routes[key]) ->
      (data = {}) =>
        URI.expand uri, (x) ->
            prop = data[x]
            delete data[x]
            prop
          .query(data)

  helpers


export class TraceView extends Component
  @childContextTypes =
    routes: PropTypes.object

  getChildContext: ->
    {
      routes: makeRoutes(this.props.routes)
    }

  render: ->
    console.log(this.props.routes)
    { trace, spans } = this.props

    $ 'section', className: 'traceview',
      $ Header,
        trace: this.props.trace
      $ 'div', className: 'container-fluid',
        $ TraceInfo, trace: trace
        $ TraceMeta, trace: trace
      $ 'div', className: 'container-fluid',
        $ TraceGraph, nodes: [trace, spans...]


class Header extends Component
  @contextTypes =
    routes: PropTypes.object

  toggleSave: ->
    { trace } = this.props

    token = document.querySelector('meta[name="csrf-token"]').content
    url = this.context.routes.traces_url(id: trace.uuid)

    response = await fetch url,
      method: 'PATCH'
      credentials: 'same-origin'
      headers:
        'Accept': 'application/json'
        'Content-Type': 'application/json'
        'X-CSRF-Token': token
      body: JSON.stringify store: !trace.store

    if response.ok
      location.reload()

  render: ->
    { trace } = this.props

    $ 'header',
      $ 'h2',
        if trace.store
          $ 'a',
            href: '#'
            onClick: => this.toggleSave()
            title: 'Trace saved'
            $ IconStar
        else
          $ 'a',
            href: '#'
            onClick: => this.toggleSave()
            title: 'Save trace'
            $ IconStarOff
        'Trace Details'
      $ 'a',
        href: this.context.routes.t_url(id: trace.uuid)
        $ 'span', trace.uuid
        $ 'small', '(direct link)'
