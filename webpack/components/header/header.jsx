import React from "react"
import PropTypes from 'prop-types'
import { Navbar, Nav, NavItem, NavDropdown, MenuItem } from 'react-bootstrap'
import { LinkContainer } from 'react-router-bootstrap'
import { NavLink } from 'react-router-dom'
import classnames from 'classnames'

export default class Header extends React.Component {
  render() {
    const {paths} = this.props
    const external_urls = [
      {text: 'Manage', iconClassName: 'glyphicon glyphicon-cog', items: [
        {text: 'Bank Accounts', url: '/app/bank_accounts', iconClassName: 'glyphicon glyphicon-book'},
        {text: 'Bank Statements', url: '/app/bank_statements', iconClassName: 'glyphicon glyphicon-list-alt'},
        {text: 'Transactions', url: '/app/bank_records', iconClassName: 'glyphicon glyphicon-shopping-cart'},
        {text: 'Audits', url: '/app/audits', iconClassName: 'glyphicon glyphicon-th-list'},
        {},
        {text: 'Statement Parsers', url: '#', iconClassName: 'glyphicon glyphicon-flash'},
      ]},
      {text: 'Logout', url: '#', iconClassName: 'glyphicon glyphicon-log-out', items: []},
    ]
    return (
      <Navbar fluid>
        <Navbar.Header>
          <Navbar.Toggle />
          <Navbar.Brand>
            <NavLink to="/app/">
              <img className="navbar-logo" src={paths.logo} />
              My Ledger
            </NavLink>
          </Navbar.Brand>
        </Navbar.Header>
        <Navbar.Collapse>
          <Nav pullRight>
            { this.renderUrls(external_urls) }
          </Nav>
        </Navbar.Collapse>
      </Navbar>
    )
  }

  renderUrls(urls) {
    return (urls || []).map(({text, url, items, iconClassName}, i) => {
      if( items && items.length ) {
        return (
          <NavDropdown key={i} title={this.renderItemText(text, iconClassName)} id={this.generateID(text)}>
            {(items || []).map(this.renderMenuItem)}
          </NavDropdown>
        )
      }
      return (<NavItem key={i} href={url}>{this.renderItemText(text, iconClassName)}</NavItem>)
    })
  }

  renderMenuItem = ({url, text, iconClassName}, i) => {
    if( !url )
      return <MenuItem key={i} divider />
    return (
      <LinkContainer key={i} to={url}>
        <MenuItem>
          {this.renderItemText(text, iconClassName)}
        </MenuItem>
      </LinkContainer>
    )
  }

  generateID(text) {
    return text.toLowerCase().replace(/\W+/g, '-')
  }

  renderItemText(text, iconClassName) {
    if( !iconClassName )
      return text
    return [
      <i key='icon' className={iconClassName}></i>,
      <span key='text'>{text}</span>
    ]
  }
}

Header.propTypes = {
  paths: PropTypes.shape({
    logo: PropTypes.string
  }).isRequired
}
