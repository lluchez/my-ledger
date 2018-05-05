import React, {Component} from 'react'
import { BrowserRouter, Switch, Route, Redirect, NavLink } from 'react-router-dom'
import Header from './header/header'
import styles from './app.scss'

const PrimaryLayout = () => (
  <div className="primary-layout">
    <header>
      <Header />
    </header>
    <main>
      <Switch>
        <Route path="/app/" exact component={HomePage} />
        <Route path="/app/bank_accounts" component={BankAccountsPage} />
        <Route path="/app/bank_statements" component={BankStatementsPage} />
        <Route path="/app/bank_records" component={TransactionsPage} />
        <Route path="/app/audits" component={AuditsPage} />
        <Redirect to="/app/" />
      </Switch>
    </main>
  </div>
)

const HomePage =() => <div>Home Page</div> /*<NavLink to="/app/users">Go to users</NavLink></div>*/
const BankAccountsPage = () => <div>Bank Accounts Page</div>
const BankStatementsPage = () => <div>Bank Statements Page</div>
const TransactionsPage = () => <div>Transactions Page</div>
const AuditsPage = () => <div>Audits Page</div>

const App = () => (
  <BrowserRouter>
    <PrimaryLayout />
  </BrowserRouter>
)


export default App
