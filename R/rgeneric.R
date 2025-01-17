## Export: inla.rgeneric.ar1.model 
## Export: inla.rgeneric.iid.model 
## Export: inla.rgeneric.define
## Export: inla.rgeneric.wrapper

##!\name{rgeneric.define}
##!\alias{rgeneric}
##!\alias{rgeneric.define}
##!\alias{inla.rgeneric.define}
##!\alias{rgeneric.ar1.model}
##!\alias{inla.rgeneric.ar1.model}
##!\alias{rgeneric.iid.model}
##!\alias{inla.rgeneric.iid.model}
##!\alias{rgeneric.wrapper}
##!\alias{inla.rgeneric.wrapper}
##!
##!\title{rgeneric models}
##!
##!\description{A framework for defining latent models in R}
##!
##!\usage{
##!inla.rgeneric.define(model = NULL, debug = FALSE, R.init = NULL, ...)
##!inla.rgeneric.iid.model(
##!        cmd = c("graph", "Q", "mu", "initial", "log.norm.const", "log.prior", "quit"),
##!        theta = NULL, args = NULL)
##!inla.rgeneric.ar1.model(
##!        cmd = c("graph", "Q", "mu", "initial", "log.norm.const", "log.prior", "quit"),
##!        theta = NULL, args = NULL)
##!inla.rgeneric.wrapper(
##!        cmd = c("graph", "Q", "mu", "initial", "log.norm.const", "log.prior", "quit"),
##!        model, theta = NULL)
##!}
##!
##!\arguments{
##!
##!  \item{model}{The definition of the model; see \code{inla.rgeneric.ar1.model}}
##!  \item{cmd}{An allowed request}
##!  \item{theta}{Values of theta}
##!  \item{debug}{Logical. Turn on/off debugging}
##!  \item{R.init}{An R-file to be loaded or sourced, when the R-engine starts. See \code{inla.load}}
##!  \item{args}{A list. A list of further args}
##!  \item{...}{Further args}
##!  \item{debug}{Logical. Enable debug output}
##!}
##!
##!\value{%%
##!  This allows a latent model to be 
##!  defined in \code{R}.
##!  See \code{inla.rgeneric.ar1.model} and
##!  \code{inla.rgeneric.iid.model} and the documentation for 
##!  worked out examples of how to define latent models in  this way.
##!  This will be somewhat slow and is intended for special cases and
##!  protyping. The function \code{inla.rgeneric.wrapper} is for
##!  internal use only.}
##!\author{Havard Rue \email{hrue@math.ntnu.no}}


`inla.rgeneric.ar1.model` = function(
    cmd = c("graph", "Q", "mu", "initial", "log.norm.const", "log.prior", "quit"),
    theta = NULL, args = NULL)
{
    ## this is an example of the 'rgeneric' model. here we implement
    ## the AR-1 model as described in inla.doc("ar1"), where 'rho' is
    ## the lag-1 correlation and 'prec' is the *marginal* (not
    ## conditional) precision.
    
    interpret.theta = function(n, theta)
    {
        ## internal helper-function to map the parameters from the internal-scale to the
        ## user-scale
        return (list(prec = exp(theta[1L]),
                     rho = 2*exp(theta[2L])/(1+exp(theta[2L])) - 1.0))
    }

    graph = function(n, theta)
    {
        ## return the graph of the model. the values of Q is only interpreted as zero or
        ## non-zero. return a sparse.matrix
        if (FALSE) {
            ## slow and easy: dense-matrices
            G = toeplitz(c(1, 1, rep(0, n-2L)))
            G = inla.as.sparse(G)
        } else {
            ## faster. we only need to define the lower-triangular of G
            i = c(
                ## diagonal
                1L, n, 2L:(n-1L),
                ## off-diagonal
                1L:(n-1L))
            j = c(
                ## diagonal
                1L, n, 2L:(n-1L),
                ## off-diagonal
                2L:n)
            x = 1 ## meaning that all are 1
            G = sparseMatrix(i=i, j=j, x=x, giveCsparse = FALSE)
        }            
        return (G)
    }

    Q = function(n, theta)
    {
        ## returns the precision matrix for given parameters
        param = interpret.theta(n, theta)
        if (FALSE) {
            ## slow and easy: dense-matrices
            Q = param$prec/(1-param$rho^2) * toeplitz(c(1+param$rho^2, -param$rho, rep(0, n-2L)))
            Q[1, 1] = Q[n, n] = param$prec/(1-param$rho^2)
            Q = inla.as.sparse(Q)
        } else {
            ## faster. we only need to define the lower-triangular Q!
            i = c(
                ## diagonal
                1L, n, 2L:(n-1L),
                ## off-diagonal
                1L:(n-1L))
            j = c(
                ## diagonal
                1L, n, 2L:(n-1L),
                ## off-diagonal
                2L:n)
            x = param$prec/(1-param$rho^2) *
                c(  ## diagonal
                    1L, 1L, rep(1+param$rho^2, n-2L),
                    ## off-diagonal
                    rep(-param$rho, n-1L))
            Q = sparseMatrix(i=i, j=j, x=x, giveCsparse=FALSE)
        }            
        return (Q)
    }

    mu = function(n, theta)
    {
        return (numeric(0))
    }
        
    log.norm.const = function(n, theta)
    {
        ## return the log(normalising constant) for the model
        param = interpret.theta(n, theta)
        prec.innovation  = param$prec / (1.0 - param$rho^2)
        val = n * (- 0.5 * log(2*pi) + 0.5 * log(prec.innovation)) + 0.5 * log(1.0 - param$rho^2)
        return (val)
    }

    log.prior = function(n, theta)
    {
        ## return the log-prior for the hyperparameters. the '+theta[1L]' is the log(Jacobian)
        ## for having a gamma prior on the precision and convert it into the prior for the
        ## log(precision).
        param = interpret.theta(n, theta)
        val = (dgamma(param$prec, shape = 1, rate = 1, log=TRUE) + theta[1L] + 
                   dnorm(theta[2L], mean = 0, sd = 1, log=TRUE))
        return (val)
    }

    initial = function(n, theta)
    {
        ## return initial values
        ntheta = 2
        return (rep(1, ntheta))
    }

    quit = function(n, theta)
    {
        return (invisible())
    }

    cmd = match.arg(cmd)
    val = do.call(cmd, args = list(n = as.integer(args$n), theta = theta))
    return (val)
}

`inla.rgeneric.iid.model` = function(
    cmd = c("graph", "Q", "mu", "initial", "log.norm.const", "log.prior", "quit"),
    theta = NULL, args = NULL)
{
    ## this is an example of the 'rgeneric' model. here we implement the iid model as described
    ## in inla.doc("iid"), without the scaling-option

    interpret.theta = function(n, theta)
    {
        return (list(prec = exp(theta[1L])))
    }

    graph = function(n, theta)
    {
        G = Diagonal(n, x= rep(1, n))
        return (G)
    }

    Q = function(n, theta)
    {
        prec = interpret.theta(n, theta)$prec
        Q = Diagonal(n, x= rep(prec, n))
        return (Q)
    }

    mu = function(n, theta)
    {
        return (numeric(0))
    }
    
    log.norm.const = function(n, theta)
    {
        prec = interpret.theta(n, theta)$prec
        val = sum(dnorm(rep(0, n), sd = 1/sqrt(prec), log=TRUE))
        return (val)
    }

    log.prior = function(n, theta)
    {
        prec = interpret.theta(n, theta)$prec
        val = dgamma(prec, shape = 1, rate = 1, log=TRUE) + theta[1L]
        return (val)
    }

    initial = function(n, theta)
    {
        ntheta = 1
        return (rep(1, ntheta))
    }

    quit = function(n, theta)
    {
        return (invisible())
    }

    cmd = match.arg(cmd)
    val = do.call(cmd, args = list(n = as.integer(args$n), theta = theta))
    return (val)
}

`inla.rgeneric.define` = function(model = NULL, debug = FALSE, R.init = NULL, ...)
{
    stopifnot(!missing(model))
    rmodel = list(
        f = list(
            model = "rgeneric", 
            rgeneric = list(
                definition = model,
                debug = debug, 
                args = list(...), 
                R.init = R.init
                )
            )
        )
    class(rmodel) = "inla.rgeneric"
    class(rmodel$f$rgeneric) = "inla.rgeneric"
    return (rmodel)
}

`inla.rgeneric.wrapper` = function(
    cmd = c("graph", "Q", "mu", "initial", "log.norm.const", "log.prior", "quit"),
    model,
    theta = NULL)
{
    debug.cat = function(...) {
        if (debug)
            cat("Rgeneric: ", ..., "\n", file = stderr())
    }

    model.orig = model
    if (is.character(model)) {
        model = get(model, envir = parent.frame())
    }
    stopifnot(inherits(model, "inla.rgeneric"))

    debug = ifelse(is.null(model$debug) || !model$debug, FALSE, TRUE)
    if (is.character(model.orig)) {
        debug.cat("Enter with cmd=", cmd, ", model=", model.orig, "theta=", theta)
    } else {
        debug.cat("Enter with cmd=", cmd, ", theta=", theta)
    }

    result = NULL
    cmd = match.arg(cmd)
    res = do.call(model$definition, args = list(cmd = cmd, theta = theta, args = model$args))
    if (cmd %in% "Q") {
        Q = inla.as.sparse(res)
        debug.cat("dim(Q)", dim(Q))
        n = dim(Q)[1L]
        stopifnot(dim(Q)[1L] == dim(Q)[2L])
        stopifnot(dim(Q)[1L] == n && dim(Q)[2L] == n)
        idx = which(Q@i <= Q@j)
        len = length(Q@i[idx])
        result = c(n, len, Q@i[idx], Q@j[idx], Q@x[idx])
    } else if (cmd %in% "graph") {
        G = inla.as.sparse(res)
        stopifnot(dim(G)[1L] == dim(G)[2L])
        diag(G) = 1
        n = dim(G)[1L]
        idx = which(G@i <= G@j)
        len = length(G@i[idx])
        debug.cat("n", n, "len", len)
        result = c(n, len, G@i[idx], G@j[idx])
    } else if (cmd %in% "mu") {
        mu = res
        debug.cat("length(mu)", length(mu))
        result = c(length(mu), mu)
    } else if (cmd %in% "initial") {
        init = res
        debug.cat("initial", init)
        result = c(length(init), init)
    } else if (cmd %in% "log.norm.const") {
        lnc = res
        debug.cat("log.norm.const", lnc)
        result = c(lnc)
    } else if (cmd %in% "log.prior") {
        lp = res
        debug.cat("log.prior", lp)
        result = c(lp)
    } else if (cmd %in% c("quit", "exit")) {
        ## nothing for the moment
        result = NULL
    } else {
        stop(paste("Unknown command", cmd))
    }

    return (as.numeric(result))
}
