import * as React from "react"
import PropTypes from "prop-types"
import { Link } from "gatsby"
import Container from 'react-bootstrap/Container';
import Nav from 'react-bootstrap/Nav';
import Navbar from 'react-bootstrap/Navbar';
import NavDropdown from 'react-bootstrap/NavDropdown';

const Header = ({ siteTitle }) => (
  /*<header
    style={{
      margin: `0 auto`,
      padding: `var(--space-4) var(--size-gutter)`,
      display: `flex`,
      alignItems: `center`,
      justifyContent: `space-between`,
    }}
  >
    <Link
      to="/"
      style={{
        fontSize: `var(--font-sm)`,
        textDecoration: `none`,
      }}
    >
      {siteTitle}
    </Link>
    <img
      alt="Gatsby logo"
      height={20}
      style={{ margin: 0 }}
      src="data:image/svg+xml,%3Csvg fill='none' viewBox='0 0 107 28' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3CclipPath id='a'%3E%3Cpath d='m0 0h106.1v28h-106.1z'/%3E%3C/clipPath%3E%3Cg clip-path='url(%23a)'%3E%3Cg fill='%23000'%3E%3Cpath clip-rule='evenodd' d='m89 11.7c-.8 0-2.2.2-3.2 1.6v-8.10005h-2.8v16.80005h2.7v-1.3c1.1 1.5 2.6 1.5999 3.2 1.5999 3 0 5-2.2999 5-5.2999s-2-5.3-4.9-5.3zm-.7 2.5c1.7 0 2.8 1.2 2.8 2.8s-1.2 2.8-2.8 2.8c-1.7 0-2.8-1.2-2.8-2.8s1.1-2.8 2.8-2.8z' fill-rule='evenodd'/%3E%3Cpath d='m71.2 21.9999v-7.6h1.9v-2.4h-1.9v-3.40005h-2.8v3.40005h-1.1v2.4h1.1v7.6z'/%3E%3Cpath clip-rule='evenodd' d='m65.6999 12h-2.9v1.3c-.8999-1.5-2.4-1.6-3.2-1.6-2.9 0-4.8999 2.4-4.8999 5.3s1.9999 5.2999 5.0999 5.2999c.8 0 2.1001-.0999 3.1001-1.5999v1.3h2.7999zm-5.1999 7.8c-1.7001 0-2.8-1.2-2.8-2.8s1.2-2.8 2.8-2.8c1.7 0 2.7999 1.2 2.7999 2.8s-1.1999 2.8-2.7999 2.8z' fill-rule='evenodd'/%3E%3Cpath d='m79.7001 14.4c-.7-.6-1.3-.7-1.6-.7-.7 0-1.1.3-1.1.8 0 .3.1.6.9.9l.7.2c.1261.0472.2621.0945.4037.1437.7571.2632 1.6751.5823 2.0963 1.2563.3.4.5 1 .5 1.7 0 .9-.3 1.8-1.1 2.5s-1.8 1.0999-3 1.0999c-2.1 0-3.2-.9999-3.9-1.6999l1.5-1.7c.6.6 1.4 1.2 2.2 1.2s1.4-.4 1.4-1.1c0-.6-.5-.9-.9-1l-.6-.2c-.0687-.0295-.1384-.0589-.2087-.0887l-.0011-.0004c-.6458-.2729-1.3496-.5704-1.8902-1.1109-.5-.5-.8-1.1-.8-1.9 0-1 .5-1.8 1-2.3.8-.6 1.8-.7 2.6-.7.7 0 1.9.1 3.2 1.1z'/%3E%3Cpath d='m98.5 20.5-4.8-8.5h3.3l3.1 5.7 2.8-5.7h3.2l-8 15.3h-3.2z'/%3E%3Cpath d='m47 13.7h7c0 .0634.01.1267.0206.1932.0227.1435.0477.3018-.0206.5068 0 4.5-3.4 8.1-8 8.1s-8-3.6-8-8.1c0-4.49995 3.6-8.09995 8-8.09995 2.6 0 5 1.2 6.5 3.3l-2.3 1.49995c-1-1.29995-2.6-2.09995-4.2-2.09995-2.9 0-4.9 2.49995-4.9 5.39995s2.1 5.3 5 5.3c2.6 0 4-1.3 4.6-3.2h-3.7z'/%3E%3C/g%3E%3Cpath d='m18 14h7c0 5.2-3.7 9.6-8.5 10.8l-13.19995-13.2c1.1-4.9 5.5-8.6 10.69995-8.6 3.7 0 6.9 1.8 8.9 4.5l-1.5 1.3c-1.7-2.3-4.4-3.8-7.4-3.8-3.9 0-7.29995 2.5-8.49995 6l11.49995 11.5c2.9-1 5.1-3.5 5.8-6.5h-4.8z' fill='%23fff'/%3E%3Cpath d='m6.2 21.7001c-2.1-2.1-3.2-4.8-3.2-7.6l10.8 10.8c-2.7 0-5.5-1.1-7.6-3.2z' fill='%23fff'/%3E%3Cpath d='m14 0c-7.7 0-14 6.3-14 14s6.3 14 14 14 14-6.3 14-14-6.3-14-14-14zm-7.8 21.8c-2.1-2.1-3.2-4.9-3.2-7.6l10.9 10.8c-2.8-.1-5.6-1.1-7.7-3.2zm10.2 2.9-13.1-13.1c1.1-4.9 5.5-8.6 10.7-8.6 3.7 0 6.9 1.8 8.9 4.5l-1.5 1.3c-1.7-2.3-4.4-3.8-7.4-3.8-3.9 0-7.2 2.5-8.5 6l11.5 11.5c2.9-1 5.1-3.5 5.8-6.5h-4.8v-2h7c0 5.2-3.7 9.6-8.6 10.7z' fill='%237026b9'/%3E%3C/g%3E%3C/svg%3E"
    />
  </header>*/
      <header id="header" className="shadow-xs">
        <Navbar bg="light" expand="lg">
          <Container>
            <Navbar.Brand href="#home">React-Bootstrap</Navbar.Brand>
            <Navbar.Toggle aria-controls="basic-navbar-nav" />
            <Navbar.Collapse id="basic-navbar-nav">
              <Nav className="me-auto">
                <Nav.Link href="#home">Home</Nav.Link>
                <Nav.Link href="#link">Link</Nav.Link>
                <NavDropdown title="Dropdown" id="basic-nav-dropdown">
                  <NavDropdown.Item href="#action/3.1">Action</NavDropdown.Item>
                  <NavDropdown.Item href="#action/3.2">
                    Another action
                  </NavDropdown.Item>
                  <NavDropdown.Item href="#action/3.3">Something</NavDropdown.Item>
                  <NavDropdown.Divider />
                  <NavDropdown.Item href="#action/3.4">
                    Separated link
                  </NavDropdown.Item>
                </NavDropdown>

                <NavDropdown title="Blog">

									<a href="#" id="mainNavBlog" className="nav-link dropdown-toggle" 
										data-bs-toggle="dropdown" 
										aria-haspopup="true" 
										aria-expanded="false">
										Blog
									</a>

									<div aria-labelledby="mainNavBlog" className="dropdown-menu dropdown-menu-clean dropdown-menu-hover dropdown-fadeinup">
								    <ul className="list-unstyled m-0 p-0">
                      <li className="dropdown-item"><a className="dropdown-link" href="blog-page-sidebar.html">With Sidebar</a></li>
                      <li className="dropdown-item"><a className="dropdown-link" href="blog-page-sidebar-no.html">Without Sidebar</a></li>
                      <li className="dropdown-item"><a className="dropdown-link" href="blog-page-article-sidebar.html">Article With Sidebar</a></li>
                      <li className="dropdown-item"><a className="dropdown-link" href="blog-page-article-sidebar-no.html">Article Without Sidebar</a></li>
								    </ul>
									</div>

                </NavDropdown>

              </Nav>
            </Navbar.Collapse>
          </Container>
        </Navbar>
        


				<div className="container position-relative">



					<form 	action="#search-page" 
							method="GET" 
							data-autosuggest="on" 

							data-mode="json" 
							data-json-max-results='10'
							data-json-related-title='Explore Smarty'
							data-json-related-item-icon='fi fi-star-empty'
							data-json-suggest-title='Suggestions for you'
							data-json-suggest-noresult='No results for'
							data-json-suggest-item-icon='fi fi-search'
							data-json-suggest-min-score='5'
							data-json-highlight-term='true'
							data-contentType='application/json; charset=utf-8'
							data-dataType='json'

							data-container="#sow-search-container" 
							data-input-min-length="2" 
							data-input-delay="250" 
							data-related-keywords="" 
							data-related-url="_ajax/search_suggest_related.json" 
							data-suggest-url="_ajax/search_suggest_input.json" 
							data-related-action="related_get" 
							data-suggest-action="suggest_get" 
							className="js-ajax-search sow-search sow-search-over hide d-inline-flex">
						<div className="sow-search-input w-100">

							<div className="input-group-over d-flex align-items-center w-100 h-100 rounded shadow-md">

								<input placeholder="what are you looking today?" aria-label="what are you looking today?" name="s" type="text" className="form-control-sow-search form-control shadow-xs" value="" autocomplete="off"></input>

								<span className="sow-search-buttons">

									
									<button aria-label="Global Search" type="submit" className="btn bg-transparent shadow-none m-0 px-2 py-1 text-muted">
										<i className="fi fi-search fs-5"></i>
									</button>

									
									<a href="javascript:;" className="btn-sow-search-toggler btn btn-light shadow-none m-0 px-2 py-1 d-inline-block d-lg-none">
										<i className="fi fi-close fs-2"></i>
									</a>

								</span>

							</div>

						</div>

						
						<div className="sow-search-container w-100 p-0 hide shadow-md" id="sow-search-container">
							<div className="sow-search-container-wrapper">

								
								<div className="sow-search-loader p-3 text-center hide">
									<i className="fi fi-circle-spin fi-spin text-muted fs-1"></i>
								</div>

								<div className="sow-search-content rounded w-100 scrollable-vertical"></div>

							</div>
						</div>
						

						<div className="sow-search-backdrop backdrop-dark hide"></div>

					</form>
					





					<nav className="navbar navbar-expand-lg navbar-light justify-content-lg-between justify-content-md-inherit">

						<div className="align-items-start">

							
							<button className="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarMainNav" aria-controls="navbarMainNav" aria-expanded="false" aria-label="Toggle navigation">
								<svg width="25" viewBox="0 0 20 20">
									<path d="M 19.9876 1.998 L -0.0108 1.998 L -0.0108 -0.0019 L 19.9876 -0.0019 L 19.9876 1.998 Z"></path>
									<path d="M 19.9876 7.9979 L -0.0108 7.9979 L -0.0108 5.9979 L 19.9876 5.9979 L 19.9876 7.9979 Z"></path>
									<path d="M 19.9876 13.9977 L -0.0108 13.9977 L -0.0108 11.9978 L 19.9876 11.9978 L 19.9876 13.9977 Z"></path>
									<path d="M 19.9876 19.9976 L -0.0108 19.9976 L -0.0108 17.9976 L 19.9876 17.9976 L 19.9876 19.9976 Z"></path>
								</svg>
							</button>


							<a className="navbar-brand" href="index.html">
								<img src="assets/images/logo/logo_dark.svg" width="110" height="38" alt="..."></img>
							</a>

						</div>




						
						<div className="collapse navbar-collapse navbar-animate-fadein" id="navbarMainNav">


							
							<div className="navbar-xs d-none">

								
								<button className="navbar-toggler pt-0" type="button" data-bs-toggle="collapse" data-bs-target="#navbarMainNav" aria-controls="navbarMainNav" aria-expanded="false" aria-label="Toggle navigation">
									<svg width="20" viewBox="0 0 20 20">
										<path d="M 20.7895 0.977 L 19.3752 -0.4364 L 10.081 8.8522 L 0.7869 -0.4364 L -0.6274 0.977 L 8.6668 10.2656 L -0.6274 19.5542 L 0.7869 20.9676 L 10.081 11.679 L 19.3752 20.9676 L 20.7895 19.5542 L 11.4953 10.2656 L 20.7895 0.977 Z"></path>
									</svg>
								</button>

								<a className="navbar-brand" href="index.html">
									<img src="assets/images/logo/logo_dark.svg" width="110" height="38" alt="..."></img>
								</a>

							</div>
							


							<ul className="navbar-nav">
								
								<li className="nav-item d-block d-sm-none">

									<div className="mb-4">
										<img width="600" height="600" className="img-fluid" src="demo.files/svg/artworks/people_crossbrowser.svg" alt="..."></img>
									</div>

									<form method="get" action="#!search" className="input-group-over mb-4 bg-light p-2 form-control-pill">
										<input type="text" name="keyword" value="" placeholder="Quick search..." className="form-control border-dashed"></input>
										<button className="btn btn-sm fi fi-search mx-3"></button>
									</form>

								</li>


                <li className="nav-item dropdown active">

                  <a href="#" id="mainNavHome" className="nav-link dropdown-toggle" 
                    data-bs-toggle="dropdown" 
                    aria-haspopup="true" 
                    aria-expanded="false">
                    Home
                  </a>

                  <div aria-labelledby="mainNavHome" className="dropdown-menu dropdown-menu-clean dropdown-menu-hover dropdown-mega-md dropdown-fadeinup">

                    <div className="row">

                      <div className="col-12 col-lg-6">
                        <ul className="list-unstyled">
                          <li className="dropdown-item">
                            <h3 className="fs-6 text-muted py-3 px-lg-4">
                              Niche pages
                            </h3>
                          </li>
                          <li className="dropdown-item"><a href="niche.restaurant.html" className="dropdown-link">Restaurant</a></li>
                          <li className="dropdown-item"><a href="niche.caffe.html" className="dropdown-link">Caffe</a></li>
                          <li className="dropdown-item"><a href="niche.tattoo.html" className="dropdown-link">Tattoo</a></li>
                          <li className="dropdown-item"><a href="niche.lawyer.html" className="dropdown-link">Lawyer</a></li>
                          <li className="dropdown-item"><a href="niche.hosting.html" className="dropdown-link">Hosting</a></li>
                          <li className="dropdown-item"><a href="niche.classifieds.html" className="dropdown-link">Classifieds</a></li>
                          <li className="dropdown-item"><a href="niche.realestate.html" className="dropdown-link">Real Estate</a></li>
                          <li className="dropdown-item"><a href="#" className="dropdown-link disabled">More soon</a></li>
                        </ul>
                      </div>

                      <div className="col-12 col-lg-6">
                        <ul className="list-unstyled">
                          <li className="dropdown-item">
                            <h3 className="fs-6 text-muted py-3 px-lg-4">
                              Landing pages
                            </h3>
                          </li>
                          <li className="dropdown-item"><a href="landing-0.html" className="dropdown-link">Default</a></li>
                          <li className="dropdown-item"><a href="landing-1.html" className="dropdown-link">Landing 1</a></li>
                          <li className="dropdown-item"><a href="landing-2.html" className="dropdown-link">Landing 2</a></li>
                          <li className="dropdown-item"><a href="landing-3.html" className="dropdown-link">Landing 3</a></li>
                          <li className="dropdown-item"><a href="landing-4.html" className="dropdown-link">Landing 4</a></li>
                          <li className="dropdown-item"><a href="landing-5.html" className="dropdown-link">Landing 5</a></li>
                          <li className="dropdown-item"><a href="landing-6.html" className="dropdown-link">Landing 6</a></li>
                          <li className="dropdown-item"><a href="landing-7.html" className="dropdown-link">Landing 7</a></li>
                          <li className="dropdown-item"><a href="landing-8.html" className="dropdown-link">Landing 8</a></li>
                        </ul>
                      </div>

                    </div>

                    <ul className="list-unstyled">
                      <li className="dropdown-divider"></li>
                      <li className="dropdown-item pt-2">
                        <a href="index.html" className="dropdown-link text-muted d-flex align-items-center">
                          <span className="pe-2">All Demos</span>
                          <svg width="18px" height="18px" xmlns="http://www.w3.org/2000/svg" fill="currentColor" className="bi bi-arrow-right-short" viewBox="0 0 16 16">  
                            <path fill-rule="evenodd" d="M4 8a.5.5 0 0 1 .5-.5h5.793L8.146 5.354a.5.5 0 1 1 .708-.708l3 3a.5.5 0 0 1 0 .708l-3 3a.5.5 0 0 1-.708-.708L10.293 8.5H4.5A.5.5 0 0 1 4 8z"></path>
                          </svg>
                        </a>
                      </li>
                    </ul>

                  </div>

                </li>


								<li className="nav-item dropdown">

									<a href="#" id="mainNavPages" className="nav-link dropdown-toggle" 
										data-bs-toggle="dropdown" 
										aria-haspopup="true" 
										aria-expanded="false">
										Pages
									</a>

									<div aria-labelledby="mainNavPages" className="dropdown-menu dropdown-menu-hover dropdown-menu-clean dropdown-fadeinup">
									    <ul className="list-unstyled m-0 p-0">
									        <li className="dropdown-item dropdown"><a href="#" className="dropdown-link" data-bs-toggle="dropdown">About</a>
									            <ul className="dropdown-menu dropdown-menu-hover dropdown-menu-block-md shadow-lg rounded-xl border-0 m-0">
									                <li className="dropdown-item"><a href="about-us-1.html" className="dropdown-link">About Us 1</a></li>
									                <li className="dropdown-item"><a href="about-us-2.html" className="dropdown-link">About Us 2</a></li>
									                <li className="dropdown-item"><a href="about-us-3.html" className="dropdown-link">About Us 3</a></li>
									                <li className="dropdown-item"><a href="about-us-4.html" className="dropdown-link">About Us 4</a></li>
									                <li className="dropdown-item"><a href="about-us-5.html" className="dropdown-link">About Us 5</a></li>
									                <li className="dropdown-divider"></li>
									                <li className="dropdown-item"><a href="about-me-1.html" className="dropdown-link">About Me 1</a></li>
									                <li className="dropdown-item"><a href="about-me-2.html" className="dropdown-link">About Me 2</a></li>
									            </ul>
									        </li>
									        <li className="dropdown-item dropdown"><a href="#" className="dropdown-link" data-bs-toggle="dropdown">Services</a>
									            <ul className="dropdown-menu dropdown-menu-hover dropdown-menu-block-md shadow-lg rounded-xl border-0 m-0">
									                <li className="dropdown-item"><a href="services-1.html" className="dropdown-link">Services 1</a></li>
									                <li className="dropdown-item"><a href="services-2.html" className="dropdown-link">Services 2</a></li>
									                <li className="dropdown-item"><a href="services-3.html" className="dropdown-link">Services 3</a></li>
									                <li className="dropdown-item"><a href="services-4.html" className="dropdown-link">Services 4</a></li>
									                <li className="dropdown-item"><a href="services-5.html" className="dropdown-link">Services 5</a></li>
									            </ul>
									        </li>
									        <li className="dropdown-item dropdown"><a href="#" className="dropdown-link" data-bs-toggle="dropdown">Contact</a>
									            <ul className="dropdown-menu dropdown-menu-hover dropdown-menu-block-md shadow-lg rounded-xl border-0 m-0">
									                <li className="dropdown-item"><a href="contact-1.html" className="dropdown-link">Contact 1</a></li>
									                <li className="dropdown-item"><a href="contact-2.html" className="dropdown-link">Contact 2</a></li>
									                <li className="dropdown-item"><a href="contact-3.html" className="dropdown-link">Contact 3</a></li>
									                <li className="dropdown-item"><a href="contact-4.html" className="dropdown-link">Contact 4</a></li>
									            </ul>
									        </li>
									        <li className="dropdown-item dropdown"><a href="#" className="dropdown-link" data-bs-toggle="dropdown">Pricing</a>
									            <ul className="dropdown-menu dropdown-menu-hover dropdown-menu-block-md shadow-lg rounded-xl border-0 m-0">
									                <li className="dropdown-item"><a href="pricing-1.html" className="dropdown-link">Pricing 1</a></li>
									                <li className="dropdown-item"><a href="pricing-2.html" className="dropdown-link">Pricing 2</a></li>
									                <li className="dropdown-item"><a href="pricing-3.html" className="dropdown-link">Pricing 3</a></li>
									                <li className="dropdown-item"><a href="pricing-4.html" className="dropdown-link">Pricing 4</a></li>
									                <li className="dropdown-item"><a href="pricing-5.html" className="dropdown-link">Pricing 5</a></li>
									            </ul>
									        </li>
									        <li className="dropdown-item dropdown"><a href="#" className="dropdown-link" data-bs-toggle="dropdown">FAQ</a>
									            <ul className="dropdown-menu dropdown-menu-hover dropdown-menu-block-md shadow-lg rounded-xl border-0 m-0">
									                <li className="dropdown-item"><a href="faq-1.html" className="dropdown-link">FAQ 1</a></li>
									                <li className="dropdown-item"><a href="faq-2.html" className="dropdown-link">FAQ 2</a></li>
									                <li className="dropdown-item"><a href="faq-3.html" className="dropdown-link">FAQ 3</a></li>
									                <li className="dropdown-item"><a href="faq-4.html" className="dropdown-link">FAQ 4</a></li>
									            </ul>
									        </li>
									        <li className="dropdown-item dropdown"><a href="#" className="dropdown-link" data-bs-toggle="dropdown">Team</a>
									            <ul className="dropdown-menu dropdown-menu-hover dropdown-menu-block-md shadow-lg rounded-xl border-0 m-0">
									                <li className="dropdown-item"><a href="team-1.html" className="dropdown-link">Team 1</a></li>
									                <li className="dropdown-item"><a href="team-2.html" className="dropdown-link">Team 2</a></li>
									            </ul>
									        </li>
									        <li className="dropdown-item dropdown"><a href="#" className="dropdown-link" data-bs-toggle="dropdown">Account</a>
									            <ul className="dropdown-menu dropdown-menu-hover dropdown-menu-block-md shadow-lg rounded-xl border-0 m-0">
									                <li className="dropdown-item"><a href="account-index.html" className="dropdown-link">Account pages (12)</a></li>
									                <li className="dropdown-divider"></li>
									                <li className="dropdown-item"><a href="account-full-signin-1.html" className="dropdown-link">Sign In/Up : Full 1</a></li>
									                <li className="dropdown-item"><a href="account-full-signin-2.html" className="dropdown-link">Sign In/Up : Full 2</a></li>
									                <li className="dropdown-item"><a href="account-onepage-signin.html" className="dropdown-link">Sign In/Up : Onepage</a></li>
									                <li className="dropdown-item"><a href="account-simple-signin.html" className="dropdown-link">Sign In/Up : Simple</a></li>
									                <li className="dropdown-item"><a href="account-modal-signin.html" className="dropdown-link">Sign In/Up : Modal</a></li>
									            </ul>
									        </li>
									        <li className="dropdown-item dropdown"><a href="#" className="dropdown-link" data-bs-toggle="dropdown">Clients / Career</a>
									            <ul className="dropdown-menu dropdown-menu-hover dropdown-menu-block-md shadow-lg rounded-xl border-0 m-0">
									                <li className="dropdown-item"><a href="clients.html" className="dropdown-link">Clients</a></li>
									                <li className="dropdown-item"><a href="career.html" className="dropdown-link">Career</a></li>
									            </ul>
									        </li>
									        <li className="dropdown-item dropdown"><a href="#" className="dropdown-link" data-bs-toggle="dropdown">Portfolio</a>
									            <ul className="dropdown-menu dropdown-menu-hover dropdown-menu-block-md shadow-lg rounded-xl border-0 m-0">
									                <li className="dropdown-item"><a href="portfolio-columns-2.html" className="dropdown-link">2 Columns</a></li>
									                <li className="dropdown-item"><a href="portfolio-columns-3.html" className="dropdown-link">3 Columns</a></li>
									                <li className="dropdown-item"><a href="portfolio-columns-4.html" className="dropdown-link">4 Columns</a></li>
									                <li className="dropdown-divider"></li>
									                <li className="dropdown-item"><a href="portfolio-single-1.html" className="dropdown-link">Single Item 1</a></li>
									                <li className="dropdown-item"><a href="portfolio-single-2.html" className="dropdown-link">Single Item 2</a></li>
									                <li className="dropdown-item"><a href="portfolio-single-3.html" className="dropdown-link">Single Item 3</a></li>
									                <li className="dropdown-item"><a href="portfolio-single-4.html" className="dropdown-link">Single Item 4</a></li>
									            </ul>
									        </li>
									        <li className="dropdown-item dropdown"><a href="#" className="dropdown-link" data-bs-toggle="dropdown">Utility</a>
									            <ul className="dropdown-menu dropdown-menu-hover dropdown-menu-up dropdown-menu-block-md shadow-lg border-0 m-0">
									                <li className="dropdown-item"><a href="404-1.html" className="dropdown-link">Error 1</a></li>
									                <li className="dropdown-item"><a href="404-2.html" className="dropdown-link">Error 2</a></li>
									                <li className="dropdown-item"><a href="404-3.html" className="dropdown-link">Error 3</a></li>
									                <li className="dropdown-item"><a href="invoice.html" className="dropdown-link">Invoice</a></li>
									                <li className="dropdown-divider"></li>
									                <li className="dropdown-item"><a href="maintenance-1.html" className="dropdown-link">Maintenance 1</a></li>
									                <li className="dropdown-item"><a href="maintenance-2.html" className="dropdown-link">Maintenance 2</a></li>
									                <li className="dropdown-divider"></li>
									                <li className="dropdown-item"><a href="comingsoon-1.html" className="dropdown-link">Coming Soon 1</a></li>
									                <li className="dropdown-item"><a href="comingsoon-2.html" className="dropdown-link">Coming Soon 2</a></li>
									                <li className="dropdown-divider"></li>
									                <li className="dropdown-item"><a href="page-cookie.html" className="dropdown-link">GDPR Page &amp; Cookie Window</a></li>
									            </ul>
									        </li>
									    </ul>
									</div>

								</li>


								<li className="nav-item dropdown">

									<a href="#" id="mainNavFeatures" className="nav-link dropdown-toggle" 
										data-bs-toggle="dropdown" 
										aria-haspopup="true" 
										aria-expanded="false">
										Features
									</a>

									<div aria-labelledby="mainNavFeatures" className="dropdown-menu dropdown-menu-hover dropdown-menu-clean dropdown-fadeinup">
									    <ul className="list-unstyled m-0 p-0">
									        <li className="dropdown-item dropdown"><a href="#" className="dropdown-link" data-bs-toggle="dropdown">Header</a>
									            <ul className="dropdown-menu dropdown-menu-hover dropdown-menu-block-md shadow-lg rounded-xl border-0 m-0">
									                <li className="dropdown-item dropdown"><a href="#" className="dropdown-link fw-bold" data-bs-toggle="dropdown">Variants</a>
									                    <ul className="dropdown-menu dropdown-menu-hover dropdown-menu-block-md shadow-lg rounded-xl border-0 m-0">
									                        <li className="dropdown-item"><a href="header-variant-1.html" className="dropdown-link">Header : Variant : 1</a></li>
									                        <li className="dropdown-item"><a href="header-variant-2.html" className="dropdown-link">Header : Variant : 2</a></li>
									                        <li className="dropdown-item"><a href="header-variant-3.html" className="dropdown-link">Header : Variant : 3</a></li>
									                        <li className="dropdown-item"><a href="header-variant-4.html" className="dropdown-link">Header : Variant : 4</a></li>
									                        <li className="dropdown-item"><a href="header-variant-5.html" className="dropdown-link">Header : Variant : 5</a></li>
									                        <li className="dropdown-item"><a href="header-variant-6.html" className="dropdown-link">Header : Variant : 6</a></li>
									                    </ul>
									                </li>
									                <li className="dropdown-divider"></li>
									                <li className="dropdown-item"><a href="header-option-light.html" className="dropdown-link">Header : Light <small className="text-muted">(default)</small></a></li>
									                <li className="dropdown-item"><a href="header-option-dark.html" className="dropdown-link">Header : Dark</a></li>
									                <li className="dropdown-item"><a href="header-option-color.html" className="dropdown-link">Header : Color</a></li>
									                <li className="dropdown-item"><a href="header-option-transparent.html" className="dropdown-link">Header : Transparent</a></li>
									                <li className="dropdown-divider"></li>
									                <li className="dropdown-item"><a href="header-option-centered.html" className="dropdown-link">Header : Centered</a></li>
									                <li className="dropdown-item"><a href="header-option-bottom.html" className="dropdown-link">Header : Bottom</a></li>
									                <li className="dropdown-item"><a href="header-option-floating.html" className="dropdown-link">Header : Floating</a></li>
									                <li className="dropdown-divider"></li>
									                <li className="dropdown-item"><a href="header-option-fixed.html" className="dropdown-link">Header : Fixed</a></li>
									                <li className="dropdown-item"><a href="header-option-reveal.html" className="dropdown-link">Header : Reveal on Scroll</a></li>
									                <li className="dropdown-divider"></li>
									                <li className="dropdown-item"><a href="header-option-ajax-search-json.html" className="dropdown-link">Ajax Search : Json</a></li>
									                <li className="dropdown-item"><a href="header-option-ajax-search-html.html" className="dropdown-link">Ajax Search : Html</a></li>
									            </ul>
									        </li>
									        <li className="dropdown-item dropdown"><a href="#" className="dropdown-link" data-bs-toggle="dropdown">Footer</a>
									            <ul className="dropdown-menu dropdown-menu-hover dropdown-menu-block-md shadow-lg rounded-xl border-0 m-0">
									                <li className="dropdown-item dropdown"><a href="#" className="dropdown-link fw-bold" data-bs-toggle="dropdown">Variants</a>
									                    <ul className="dropdown-menu dropdown-menu-hover dropdown-menu-block-md shadow-lg rounded-xl border-0 m-0">
									                        <li className="dropdown-item"><a href="footer-variant-1.html#footer" className="dropdown-link">Footer : Variant : 1</a></li>
									                        <li className="dropdown-item"><a href="footer-variant-2.html#footer" className="dropdown-link">Footer : Variant : 2</a></li>
									                        <li className="dropdown-item"><a href="footer-variant-3.html#footer" className="dropdown-link">Footer : Variant : 3</a></li>
									                        <li className="dropdown-item"><a href="footer-variant-4.html#footer" className="dropdown-link">Footer : Variant : 4</a></li>
									                        <li className="dropdown-item"><a href="footer-variant-5.html#footer" className="dropdown-link">Footer : Variant : 5</a></li>
									                        <li className="dropdown-item"><a href="footer-variant-6.html#footer" className="dropdown-link">Footer : Variant : 6</a></li>
									                    </ul>
									                </li>
									                <li className="dropdown-divider"></li>
									                <li className="dropdown-item"><a href="footer-option-light.html" className="dropdown-link">Footer : Light</a></li>
									                <li className="dropdown-item"><a href="footer-option-dark.html" className="dropdown-link">Footer : Dark <small className="text-muted">(default)</small></a></li>
									                <li className="dropdown-item"><a href="footer-option-image.html" className="dropdown-link">Footer : Image</a></li>
									            </ul>
									        </li>
									        <li className="dropdown-item dropdown"><a href="#" className="dropdown-link" data-bs-toggle="dropdown">Sliders</a>
									            <ul className="dropdown-menu dropdown-menu-hover dropdown-menu-block-md shadow-lg rounded-xl border-0 m-0">
									                <li className="dropdown-item"><a href="slider-swiper.html" className="dropdown-link">Swiper Slider</a></li>
									            </ul>
									        </li>
									        <li className="dropdown-item dropdown"><a href="#" className="dropdown-link" data-bs-toggle="dropdown">Page Title</a>
									            <ul className="dropdown-menu dropdown-menu-hover dropdown-menu-block-md shadow-lg rounded-xl border-0 m-0">
									                <li className="dropdown-item"><a href="page-title-classic.html" className="dropdown-link">Page Title : Classic</a></li>
									                <li className="dropdown-item"><a href="page-title-alternate.html" className="dropdown-link">Page Title : Alternate</a></li>
									                <li className="dropdown-item"><a href="page-title-color.html" className="dropdown-link">Page Title : Color + Nav</a></li>
									                <li className="dropdown-item"><a href="page-title-clean.html" className="dropdown-link">Page Title : Clean</a></li>
									                <li className="dropdown-item"><a href="page-title-parallax-1.html" className="dropdown-link">Page Title : Parallax 1</a></li>
									                <li className="dropdown-item"><a href="page-title-parallax-2.html" className="dropdown-link">Page Title : Parallax 2</a></li>
									            </ul>
									        </li>
									        <li className="dropdown-item dropdown"><a href="#" className="dropdown-link" data-bs-toggle="dropdown">Sidebar</a>
									            <ul className="dropdown-menu dropdown-menu-hover dropdown-menu-block-md shadow-lg rounded-xl border-0 m-0">
									                <li className="dropdown-item"><a href="sidebar-float-cart.html" className="dropdown-link">Sidebar : Cart</a></li>
									                <li className="dropdown-divider"></li>
									                <li className="dropdown-item"><a href="sidebar-float-dark.html" className="dropdown-link">Sidebar : Float : Dark</a></li>
									                <li className="dropdown-item"><a href="sidebar-float-light.html" className="dropdown-link">Sidebar : Float : Light</a></li>
									                <li className="dropdown-divider"></li>
									                <li className="dropdown-item"><a href="sidebar-static-dark.html" className="dropdown-link">Sidebar : Static : Dark</a></li>
									                <li className="dropdown-item"><a href="sidebar-static-light.html" className="dropdown-link">Sidebar : Static : Light</a></li>
									                <li className="dropdown-divider"></li>
									                <li className="dropdown-item"><span className="d-block text-muted py-2 px-4 small fw-bold">Same as admin</span></li>
									                <li className="dropdown-item"><a href="sidebar-float-admin-color.html" className="dropdown-link">Sidebar : Float</a></li>
									                <li className="dropdown-item"><a href="sidebar-static-admin-color.html" className="dropdown-link">Sidebar : Static</a></li>
									            </ul>
									        </li>
									        <li className="dropdown-item">
									        	<a href="header-dropdown.html" className="dropdown-link fw-medium">
									        		Menu Dropdowns
									        	</a>
									        </li>
									        <li className="dropdown-divider"></li>
									        <li className="dropdown-item"><a href="layout-boxed-1.html" className="dropdown-link">Boxed Layout</a></li>
									        <li className="dropdown-item"><a href="layout-boxed-0.html" className="dropdown-link">Boxed + Header Over</a></li>
									        <li className="dropdown-item"><a href="layout-boxed-2.html" className="dropdown-link">Boxed + Background</a></li>
									    </ul>
									</div>

								</li>


								<li className="nav-item dropdown">

									<a href="#" id="mainNavBlog" className="nav-link dropdown-toggle" 
										data-bs-toggle="dropdown" 
										aria-haspopup="true" 
										aria-expanded="false">
										Blog
									</a>

									<div aria-labelledby="mainNavBlog" className="dropdown-menu dropdown-menu-clean dropdown-menu-hover dropdown-fadeinup">
								    <ul className="list-unstyled m-0 p-0">
                      <li className="dropdown-item"><a className="dropdown-link" href="blog-page-sidebar.html">With Sidebar</a></li>
                      <li className="dropdown-item"><a className="dropdown-link" href="blog-page-sidebar-no.html">Without Sidebar</a></li>
                      <li className="dropdown-item"><a className="dropdown-link" href="blog-page-article-sidebar.html">Article With Sidebar</a></li>
                      <li className="dropdown-item"><a className="dropdown-link" href="blog-page-article-sidebar-no.html">Article Without Sidebar</a></li>
								    </ul>
									</div>

								</li>


								<li className="nav-item dropdown active">

									<a href="#" id="mainNavDemo" className="nav-link dropdown-toggle" 
										data-bs-toggle="dropdown" 
										aria-haspopup="true" 
										aria-expanded="false">
										Demos
									</a>

									<div aria-labelledby="mainNavDemo" className="dropdown-menu dropdown-menu-clean dropdown-menu-hover end-0 dropdown-fadeinup">
								    <ul className="list-unstyled m-0 p-0">
							        <li className="dropdown-item dropdown">
							        	<a href="#" className="dropdown-link" data-bs-toggle="dropdown">Admin <span className="small text-muted">(2 layouts)</span></a>
						            <ul className="dropdown-menu dropdown-menu-hover dropdown-menu-block-md shadow-lg rounded-xl border-0 m-0">
					                <li className="dropdown-item"><a href="../html_admin/index.html" target="_blank" rel="noopener" className="dropdown-link">Layout 1</a></li>
					                <li className="dropdown-item"><a href="../html_admin/layout-2.html" target="_blank" rel="noopener" className="dropdown-link">Layout 2</a></li>
						            </ul>
							        </li>
							        <li className="dropdown-item"><a href="shop-index-1.html" target="_blank" rel="noopener" className="dropdown-link">Ecommerce <span className="small text-muted">(44 pages)</span></a></li>
							        <li className="dropdown-item"><a href="niche.realestate.html" target="_blank" rel="noopener" className="dropdown-link">Real estate <span className="small text-muted">(5 pages)</span></a></li>
							        <li className="dropdown-item"><a href="niche.classifieds.html" target="_blank" rel="noopener" className="dropdown-link">Classifieds <span className="small text-muted">(3 pages)</span></a></li>
							        <li className="dropdown-item"><a href="fullajax-index.html" target="_blank" rel="noopener" className="dropdown-link">Full Ajax <span className="small text-muted">(14 pages)</span></a></li>
							        <li className="dropdown-item"><a href="forum-index.html" rel="noopener" className="dropdown-link">Forum <span className="small text-muted">(3 pages)</span></a></li>
							        <li className="dropdown-item dropdown">
							        	<a href="#" className="dropdown-link" data-bs-toggle="dropdown">Help center <span className="small text-muted">(2 layouts)</span></a>
						            <ul className="dropdown-menu dropdown-menu-hover dropdown-menu-block-md shadow-lg rounded-xl border-0 m-0">
					                <li className="dropdown-item"><a href="help-center-1-index.html" className="dropdown-link">Layout 1 <span className="small text-muted">(2 pages)</span></a></li>
					                <li className="dropdown-item"><a href="help-center-2-index.html" className="dropdown-link">Layout 2 <span className="small text-muted">(3 pages)</span></a></li>
						            </ul>
							        </li>
								    </ul>
									</div>

								</li>


								<li className="nav-item dropdown">

									<a href="#" id="mainNavDocumentation" className="nav-link dropdown-toggle nav-link-caret-hide" 
										data-bs-toggle="dropdown" 
										aria-haspopup="true" 
										aria-expanded="false">
										<span>Documentation</span>
									</a>

									<div aria-labelledby="mainNavDocumentation" className="dropdown-menu dropdown-menu-clean dropdown-menu-hover end-0 w-300 dropdown-fadeinup">										
										
										<a href="documentation/index.html" className="dropdown-item py-4 d-flex">

											<span className="flex-none">
												<svg width="26" height="26" xmlns="http://www.w3.org/2000/svg" fill="currentColor" className="bi bi-file-earmark-medical" viewBox="0 0 16 16">  
												  <path d="M7.5 5.5a.5.5 0 0 0-1 0v.634l-.549-.317a.5.5 0 1 0-.5.866L6 7l-.549.317a.5.5 0 1 0 .5.866l.549-.317V8.5a.5.5 0 1 0 1 0v-.634l.549.317a.5.5 0 1 0 .5-.866L8 7l.549-.317a.5.5 0 1 0-.5-.866l-.549.317V5.5zm-2 4.5a.5.5 0 0 0 0 1h5a.5.5 0 0 0 0-1h-5zm0 2a.5.5 0 0 0 0 1h5a.5.5 0 0 0 0-1h-5z"></path>  
												  <path d="M14 14V4.5L9.5 0H4a2 2 0 0 0-2 2v12a2 2 0 0 0 2 2h8a2 2 0 0 0 2-2zM9.5 3A1.5 1.5 0 0 0 11 4.5h2V14a1 1 0 0 1-1 1H4a1 1 0 0 1-1-1V2a1 1 0 0 1 1-1h5.5v2z"></path>
												</svg>
											</span>

											<span className="ps-3">
												<span className="d-block mb-1">Documentation</span>
												<small className="d-block text-muted text-wrap">
													Your development guide to work with Smarty
												</small>
											</span>
										</a>

										<a href="__elements.html" target="_blank" rel="noopener" className="dropdown-item py-4 d-flex border-top">

											<span className="flex-none">
												<svg width="26" height="26" xmlns="http://www.w3.org/2000/svg" fill="currentColor" className="bi bi-layout-wtf" viewBox="0 0 16 16">  
												  <path d="M5 1v8H1V1h4zM1 0a1 1 0 0 0-1 1v8a1 1 0 0 0 1 1h4a1 1 0 0 0 1-1V1a1 1 0 0 0-1-1H1zm13 2v5H9V2h5zM9 1a1 1 0 0 0-1 1v5a1 1 0 0 0 1 1h5a1 1 0 0 0 1-1V2a1 1 0 0 0-1-1H9zM5 13v2H3v-2h2zm-2-1a1 1 0 0 0-1 1v2a1 1 0 0 0 1 1h2a1 1 0 0 0 1-1v-2a1 1 0 0 0-1-1H3zm12-1v2H9v-2h6zm-6-1a1 1 0 0 0-1 1v2a1 1 0 0 0 1 1h6a1 1 0 0 0 1-1v-2a1 1 0 0 0-1-1H9z"></path>
												</svg>
											</span>

											<span className="ps-3">
												<span className="d-block mb-1">Elements</span>
												<small className="d-block text-muted text-wrap">
													Various uncategorized elements ready to use
												</small>
											</span>
										</a>

									</div>

								</li>




								<li className="nav-item d-block d-sm-none text-center mb-4">

									<h3 className="h6 text-muted">Follow Us</h3>

										
									<a href="#" className="btn btn-sm btn-facebook transition-hover-top mb-2 rounded-circle text-white" rel="noopener">
										<i className="fi fi-social-facebook"></i> 
									</a>

									
									<a href="#" className="btn btn-sm btn-twitter transition-hover-top mb-2 rounded-circle text-white" rel="noopener">
										<i className="fi fi-social-twitter"></i> 
									</a>

									
									<a href="#" className="btn btn-sm btn-linkedin transition-hover-top mb-2 rounded-circle text-white" rel="noopener">
										<i className="fi fi-social-linkedin"></i> 
									</a>

									
									<a href="#" className="btn btn-sm btn-youtube transition-hover-top mb-2 rounded-circle text-white" rel="noopener">
										<i className="fi fi-social-youtube"></i> 
									</a>

								</li>



								
								<li className="nav-item d-block d-sm-none">
									<a target="_blank" href="#buy_now" className="btn w-100 btn-primary shadow-none text-white m-0">
										Get Smarty
									</a>
								</li>

							</ul>
							


						</div>





						
						<ul className="list-inline list-unstyled mb-0 d-flex align-items-end">



							<li className="list-inline-item mx-1 dropdown">

								<a href="#" aria-label="website search" className="btn-sow-search-toggler btn btn-sm rounded-circle btn-light bg-transparent text-muted shadow-none">
									<i className="fi fi-search"></i>
								</a>

							</li>

						</ul>
						



					</nav>

				</div>

			</header>
)

Header.propTypes = {
  siteTitle: PropTypes.string,
}

Header.defaultProps = {
  siteTitle: ``,
}

export default Header
