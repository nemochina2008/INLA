## Export: inla.qsample

##! \name{qsample}
##! \alias{inla.qsample}
##! \alias{qsample}
##! 
##! \title{Generate samples from a GMRF using the GMRFLib implementation}
##! 
##! \description{This function generate samples from a GMRF using the GMRFLib implementation}
##! \usage{
##! inla.qsample(
##!        n = 1L,
##!        Q,
##!        b,
##!        mu, 
##!        sample,
##!        constr,
##!        reordering = inla.reorderings(),
##!        seed = 0L,
##!        logdens = ifelse(missing(sample), FALSE, TRUE),
##!        compute.mean = ifelse(missing(sample), FALSE, TRUE))
##! }
##! 
##! \arguments{
##!   \item{n}{Number of samples. Only used if \code{missing(sample)}}
##!   \item{Q}{The precision matrix or a filename containing it.}
##!   \item{b}{The linear term}
##!   \item{mu}{The mu term}
##!   \item{sample}{A matrix of optional samples where each column is a sample. If set, then evaluate the log-density for each sample only.}
##!   \item{constr}{Optional linear constraints; see \code{?INLA::f} and argument \code{extraconstr}}
##!   \item{reordering}{The type of reordering algorithm to be used; either one of the names listed in \code{inla.reorderings()}
##!        or the output from \code{inla.qreordering(Q)}.
##!        The default is "auto" which try several reordering algorithm and use the best one for this particular matrix.}
##!   \item{seed}{Control the RNG. If \code{seed=0L} then GMRFLib will set the seed intelligently/at 'random'.
##!               If \code{seed < 0L}  then the saved state of the RNG will be reused if possible, otherwise,
##!               GMRFLib will set the seed intelligently/at 'random'.
##!               If \code{seed > 0L} then this value is used as the seed for the RNG.}
##!   \item{logdens}{If \code{TRUE}, compute also the log-density of each sample. Note that the output format then change.}
##!   \item{compute.mean}{If \code{TRUE}, compute also the (constrained) mean. Note that the output format then change.}
##!}
##!\value{
##!      The log-density has form {-1/2(x-mu)^T Q (x-mu) + b^T x}
##!
##!  If \code{logdens} is \code{FALSE},  then \code{inla.qsample} returns 
##!  the samples in a matrix,  where each column is a sample. 
##!  If \code{logdens} or \code{compute.mean} is \code{TRUE}, then a list 
##!   with names \code{sample}, 
##!  \code{logdens} and \code{mean} is returned. The samples are stored in the matrix
##!  \code{sample} where each column is a sample, and the log
##!  densities of each sample are stored as the vector \code{logdens}.
##!  The mean (include corrections for the constraints,  if any) is store in
##!  the vector \code{mean}. 
##!}
##!\author{Havard Rue \email{hrue@math.ntnu.no}}
##! 
##!\examples{
##! g = system.file("demodata/germany.graph", package="INLA")
##! Q = inla.graph2matrix(g)
##! diag(Q) = dim(Q)[1L]
##! x = inla.qsample(10, Q)
##! \dontrun{matplot(x)}
##! x = inla.qsample(10, Q, logdens=TRUE)
##! \dontrun{matplot(x$sample)}
##!
##! n = 3
##! Q = diag(n)
##! ns = 2
##! 
##! ## sample and evaluate a sample
##! x = inla.qsample(n, Q=Q, logdens=TRUE)
##! xx = inla.qsample(Q=Q,  sample = x$sample)
##! print(x$logdens - xx$logdens)
##! 
##! ## the use of a constraint
##! constr = list(A = matrix(rep(1, n), 1, n), e = 0)
##! x = inla.qsample(n, Q=Q, constr=constr)
##! print(constr$A \%*\% x)
##! 
##! ## control the RNG
##! x = inla.qsample(n, Q=Q, seed = 123)
##! ## restart from same seed,  only sample 1
##! xx = inla.qsample(n=1, Q=Q, seed = 123)
##! ## continue from the save state, sample the remaining 2
##! xxx = inla.qsample(n=n-1, Q=Q, seed = -1)
##! ## should be 0
##! print(x - cbind(xx, xxx))
##!}

`inla.qsample` = function(
        n = 1L,
        Q,
        b,
        mu, 
        sample,
        constr,
        reordering = inla.reorderings(),
        seed = 0L,
        logdens = ifelse(missing(sample), FALSE, TRUE), 
        compute.mean = ifelse(missing(sample), FALSE, TRUE))
{
    stopifnot(!missing(Q))
    stopifnot(n >= 1L)

    if (is.list(reordering)) {
        ## argument is the output from inla.qreordering()
        reordering = reordering$name
    }
    reordering = match.arg(reordering)

    Q = inla.sparse.check(Q)
    if (is(Q, "dgTMatrix")) {
        Q.file = inla.write.fmesher.file(Q)
        remove = TRUE
    } else if (is.character(Q)) {
        Q.file = Q
        remove = FALSE
    } else {
        stop("This should not happen.")
    }

    b.file = inla.tempfile()
    mu.file = inla.tempfile()
    constr.file = inla.tempfile()
    x.file = inla.tempfile()
    sample.file = inla.tempfile()
    rng.file = inla.tempfile()
    cmean.file = inla.tempfile()
    
    if (!missing(b)) {
        stopifnot(length(b) == nrow(Q))
        b = matrix(b, nrow(Q), 1)
        inla.write.fmesher.file(b, filename = b.file)
    } 

    if (!missing(mu)) {
        stopifnot(length(mu) == nrow(Q))
        mu = matrix(mu, nrow(Q), 1)
        inla.write.fmesher.file(mu, filename = mu.file)
    } 

    if (!missing(constr) && !is.null(constr)) {
        stopifnot(is.list(constr))
        A = as.matrix(constr$A)
        e = as.numeric(constr$e)
        stopifnot(ncol(A) == ncol(Q))
        stopifnot(nrow(A) == length(e))
        xx = matrix(c(nrow(A), c(A), c(e)), ncol = 1)
        inla.write.fmesher.file(xx, filename = constr.file)
    } 

    if (!missing(sample) && !is.null(sample)) {
        sample = as.matrix(sample)
        stopifnot(nrow(sample) == nrow(Q))
        stopifnot(ncol(sample) > 0L)
        inla.write.fmesher.file(sample, filename = sample.file)
        n = ncol(sample) ## redefine n here
    }

    envir = inla.get.inlaEnv()
    if (seed < 0L) {
        if (!exists("GMRFLib.rng.state", envir = envir)) {
            seed = 0L
        } else {
            rng.state = get("GMRFLib.rng.state", envir = envir)
            fp = file(rng.file, "wb")
            writeBin(as.raw(rng.state), fp)
            close(fp)
        }
    }

    if (inla.os("linux") || inla.os("mac")) {
        s = system(paste(shQuote(inla.getOption("inla.call")), "-s -m qsample", 
            "-r", reordering, "-z", seed, Q.file, x.file, as.integer(n), rng.file,
            sample.file, b.file, mu.file, constr.file, cmean.file), intern=TRUE)
    } else if(inla.os("windows")) {
        s = system(paste(shQuote(inla.getOption("inla.call")), "-s -m qsample",
            "-r", reordering, "-z", seed, Q.file, x.file, as.integer(n), rng.file,
            sample.file, b.file, mu.file, constr.file, cmean.file), intern=TRUE)
    } else {
        stop("\n\tNot supported architecture.")
    }

    if (remove) {
        unlink(Q.file)
    }

    fp = file(rng.file, "rb")
    siz = file.info(rng.file)$size
    rng.state = readBin(fp, raw(), siz)
    close(fp)    
    assign("GMRFLib.rng.state", rng.state, envir = envir)
    unlink(rng.file)

    x = inla.read.fmesher.file(x.file)
    cmean = inla.read.fmesher.file(cmean.file)
    unlink(x.file)
    unlink(cmean.file)

    nx = dim(Q)[1L]
    samples = matrix(x[-(nx + 1L),, drop=FALSE], nx, n)
    colnames(samples) = paste("sample", 1L:n, sep="")
    rownames(samples) = paste("x", 1L:nx, sep="")
    ld = c(x[nx+1L, ])
    names(ld) = paste("logdens", 1L:n, sep="")

    unlink(b.file)
    unlink(mu.file)
    unlink(constr.file)
    unlink(sample.file)

    if (logdens || compute.mean) {
        return (list(sample=samples, logdens = ld, mean = c(cmean)))
    } else {
        return (samples)
    }
}
