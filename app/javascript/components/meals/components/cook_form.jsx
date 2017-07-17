import React from 'react'
import Bills from './bills'
import Meal from './meal'
import { inject, observer } from 'mobx-react'


const CookForm = inject("store")(
  observer(({ store }) =>
    <h2>
      Hello, from CookForm!
    </h2>
  )
)

export default CookForm


// class CookForm extends React.Component {
//   render() {
//     const loaded = this.props.store.currentLoaded

//     let component = null
//     if(loaded) {
//       component = (
//         <form>
//           <Bills store={this.props.store} />
//         </form>
//       )
//     } else {
//       component = <h3>Loading "CookForm" component...</h3>
//     }

//     return(
//       <div>
//         <h3>Cook Form</h3>
//         {component}
//       </div>
//     )
//   }
// }

// export default observer(CookForm)
