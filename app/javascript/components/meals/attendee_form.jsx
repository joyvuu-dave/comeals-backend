import React from 'react'
import { LocalForm, Control } from 'react-redux-form'

class AttendeeForm extends React.Component {
  handleChange(values) {
    // console.log('change', values)
    // window.alert('Change to Attendee Form!')
    // axios.post("http://api.comeals.dev/api/v1/residents/token", {
    //   email: values.email,
    //   password: values.password
    // })
    // .then(function (response) {
    //   if(response.status === 200) {
    //     console.log('data', response.data)
    //     Cookie.set('token', response.data.token, { expires: 7300, domain: '.comeals.dev' })
    //     window.location.href = `http://${response.data.slug}.comeals.dev/calendar`
    //   }
    // })
    // .catch(function (error) {
    //   if (error.response) {
    //     // The request was made and the server responded with a status code
    //     // that falls out of the range of 2xx
    //     const data = error.response.data
    //     const status = error.response.status
    //     const headers = error.response.headers

    //     window.alert(data.message)
    //   } else if (error.request) {
    //     // The request was made but no response was received
    //     // `error.request` is an instance of XMLHttpRequest in the browser and an instance of
    //     // http.ClientRequest in node.js
    //     const request = error.request
    //   } else {
    //     // Something happened in setting up the request that triggered an Error
    //     const message = error.message
    //   }
    //   const config = error.config
    // })
  }

  handleUpdate(form) {
    if(!form.$form.pristine) {
      console.log('update', form)
    }
  }

  handleSubmit(values) {
    //console.log('submit', values)
  }

  render() {
    return(
      <div>
        <h3>Attendee Form</h3>
        <LocalForm key="attendee-form"
          onUpdate={(form) => this.handleUpdate(form)}
          onChange={(values) => this.handleChange(values)}
          onSubmit={(values) => this.handleSubmit(values)}
        >
          <label>Person A</label>
          <Control.checkbox model=".person-a-atten" />
          Late<Control.checkbox model=".person-a-late" />
          Veg<Control.checkbox model=".person-a-veg" />
          <Control.button model=".person-a-guests">Add Guest</Control.button>
          <br />

          <label>Person B</label>
          <Control.checkbox model=".person-b-atten" />
          Late<Control.checkbox model=".person-b-late" />
          Veg<Control.checkbox model=".person-b-veg" />
          <Control.button model=".person-b-guests">Add Guest</Control.button>
          <br />

          <label>Person C</label>
          <Control.checkbox model=".person-c-atten" />
          Late<Control.checkbox model=".person-c-late" />
          Veg<Control.checkbox model=".person-c-veg" />
          <Control.button model=".person-c-guests">Add Guest</Control.button>
        </LocalForm>
      </div>
    )
  }
}

export default AttendeeForm
