import React from 'react'
import { LocalForm, Control } from 'react-redux-form'
import axios from 'axios'
import Cookie from 'js-cookie'

class SignUp extends React.Component {
  handleChange(values) {
    console.log("value change", values)
  }

  handleUpdate(form) {
    console.log("form update", form)
  }

  handleSubmit(values) {
    axios.post("http://api.comeals.dev/api/v1/managers", {
      email: values.email,
      password: values.password
    })
    .then(function (response) {
      if(response.status === 200) {
        Cookie.set('token', response.data.token, { expires: 365 })
        console.log('Manager created successfully!')
        window.location.href = `https://www.comeals.dev/manager/${response.data.id}`
      } else {
        window.alert('Manager could not be created!')
      }
    })
  }


  render() {
    return (
      <LocalForm
        onUpdate={(form) => this.handleUpdate(form)}
        onChange={(values) => this.handleChange(values)}
        onSubmit={(values) => this.handleSubmit(values)}
      >
        <label>email</label>
        <Control.text model=".email" />

        <label>password</label>
        <Control type="password" model=".password" />

        <button type="submit">Submit</button>
      </LocalForm>
    )
  }
}

export default SignUp
