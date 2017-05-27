/* eslint no-console:0 */
// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.
//
// To reference this file, add <%= javascript_pack_tag 'application' %> to the appropriate
// layout file, like app/views/layouts/application.html.erb

// Community Pages
import CommunitiesNew from 'components/communities/new'
import CommunitiesShow from 'components/communities/show'

// Manager Pages
import ManagersLogin from 'components/managers/login'
import ManagersShow from 'components/managers/show'
import ManagersSignUp from 'components/managers/sign_up'


// Resident Pages
import ResidentsCalendar from 'components/residents/calendar'
import ResidentsLogin from 'components/residents/login'

import WebpackerReact from 'webpacker-react'
WebpackerReact.setup({
  CommunitiesNew,
  CommunitiesShow,
  ManagersLogin,
  ManagersShow,
  ManagersSignUp,
  ResidentsCalendar,
  ResidentsLogin
})
