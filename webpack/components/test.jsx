import React, {Component} from 'react'
import Button from 'react-bootstrap/lib/Button'
import classnames from 'classnames'
import styles from './test.scss'


export default class Test extends Component {
  render() {
    return (
      <div className={styles.root}>
        <div className={classnames(styles.test, styles.bold)}>I'm a <b>React</b> component</div>
        <div><Button bsStyle="success">Bootstrap Button</Button></div>
      </div>
    )
  }
}
