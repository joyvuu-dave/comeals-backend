import React from 'react'
import { inject, observer } from 'mobx-react'

const CooksBox = inject("store")(
  observer(({store}) =>
    <div className="meal-box cooks">
      <h2 className="title">Cooks</h2>
      <table className="table is-bordered is-striped is-narrow">
        <tbody>
          <tr>
            <td>Patches</td>
            <td>$9.99</td>
          </tr>
          <tr>
            <td>Peanut</td>
            <td>$1,000</td>
          </tr>
          <tr>
            <td>Joslyn</td>
            <td></td>
          </tr>
        </tbody>
      </table>
    </div>
  )
)

export default CooksBox;
