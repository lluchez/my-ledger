import React, {Component} from 'react'
// import App from '../../components/app'
const root = '/app'


class Audits extends Component {
  render() {
    console.log('Audit.render')
    return <div>App Page</div>
  }
}

export function rootRoute() {
  return {
    path: root,
    // exact: true,
    component: () => <div>Root Page</div>,
  }
}

export function homeRoute() {
  return {
    path: '/',
    exact: true,
    component: () => <div>Home Page</div>,
  }
}

export function bankAccountsRoute() {
  return {
    path: '/bank_accounts',
    component: () => <div>Bank Accounts</div>,
  }
}

export function bankStatementsRoute() {
  return {
    path: '/bank_statements',
    component: () => <div>Bank Statements</div>,
  }
}

export function bankRecordsRoute() {
  return {
    path: '/bank_records',
    component: () => <div>Bank Records</div>,
  }
}

export function auditsRoute() {
  return {
    path: '/audits',
    component: Audits,
  }
}

export function statementParsersRoute() {
  return {
    path: '/statement_parsers',
    component: () => <div>Statements Parsers</div>,
  }
}
