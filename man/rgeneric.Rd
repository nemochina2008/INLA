%%
%% WARNING! DO NOT EDIT!
%% This file is automatically generated from rgeneric.R
%%
\name{rgeneric.define}
\alias{rgeneric}
\alias{rgeneric.define}
\alias{inla.rgeneric.define}
\alias{rgeneric.ar1.model}
\alias{inla.rgeneric.ar1.model}
\alias{rgeneric.iid.model}
\alias{inla.rgeneric.iid.model}
\alias{rgeneric.wrapper}
\alias{inla.rgeneric.wrapper}

\title{rgeneric models}

\description{A framework for defining latent models in R}

\usage{
inla.rgeneric.define(model = NULL, debug = FALSE, R.init = NULL, ...)
inla.rgeneric.iid.model(
        cmd = c("graph", "Q", "mu", "initial", "log.norm.const", "log.prior", "quit"),
        theta = NULL, args = NULL)
inla.rgeneric.ar1.model(
        cmd = c("graph", "Q", "mu", "initial", "log.norm.const", "log.prior", "quit"),
        theta = NULL, args = NULL)
inla.rgeneric.wrapper(
        cmd = c("graph", "Q", "mu", "initial", "log.norm.const", "log.prior", "quit"),
        model, theta = NULL)
}

\arguments{

  \item{model}{The definition of the model; see \code{inla.rgeneric.ar1.model}}
  \item{cmd}{An allowed request}
  \item{theta}{Values of theta}
  \item{debug}{Logical. Turn on/off debugging}
  \item{R.init}{An R-file to be loaded or sourced, when the R-engine starts. See \code{inla.load}}
  \item{args}{A list. A list of further args}
  \item{...}{Further args}
  \item{debug}{Logical. Enable debug output}
}

\value{%%
  This allows a latent model to be 
  defined in \code{R}.
  See \code{inla.rgeneric.ar1.model} and
  \code{inla.rgeneric.iid.model} and the documentation for 
  worked out examples of how to define latent models in  this way.
  This will be somewhat slow and is intended for special cases and
  protyping. The function \code{inla.rgeneric.wrapper} is for
  internal use only.}
\author{Havard Rue \email{hrue@math.ntnu.no}}
