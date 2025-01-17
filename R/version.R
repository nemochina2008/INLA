## Export: inla.version

##!\name{inla.version}
##!\alias{version}
##!\alias{inla.version}
##!
##!\title{Show the version of the INLA-package}
##!
##!\description{Show the version of the INLA-package}
##!
##!\usage{
##!inla.version(what = c("default",
##!                      "version", 
##!                      "info", 
##!                      "hgid",
##!                      "rinla",
##!                      "inla",
##!                      "date",
##!                      "bdate"))
##!}
##!
##!\arguments{
##!  \item{what}{What to show version of}
##!}
##!
##!\value{%%
##!  \code{inla.version} either display the current version information using \code{cat}
##!  with
##!  \code{default} or \code{info},  or return the version number/information
##!  for other spesific requests through the call.
##!}
##!%%
##!
##!\author{Havard Rue \email{hrue@math.ntnu.no}}
##!
##!\examples{
##!## Summary of all
##!inla.version()
##!## The building date
##!inla.version("bdate")
##!}

`inla.version` = function (what = c("default",
                                   "version", 
                                   "info", 
                                   "hgid",
                                   "rinla",
                                   "inla",
                                   "date",
                                   "bdate"))
{
    rinla.hgid =  inla.trim("hgid: 7e45fc2b7a2f  date: Tue Jan 31 09:14:12 2017 +0300")
    inla.hgid  =  inla.trim("hgid: 7e45fc2b7a2f  date: Tue Jan 31 09:14:12 2017 +0300")
    date       =  inla.trim("Tue 31 Jan 09:27:31 EAT 2017")
    bdate      =  inla.trim("201701310927")
    version      =  inla.trim("0.0-1485844051")
    what = match.arg(what)

    if (what %in% c("default", "info")) {

        cat("\n")
        cat(paste("\n\tINLA version ............: ",  version, "\n",  sep=""))
        cat(paste(  "\tINLA date ...............: ",  date, "\n",  sep=""))
        cat(paste(  "\tINLA hgid ...............: ", rinla.hgid, "\n", sep=""))
        cat(paste(  "\tINLA-program hgid .......: ", inla.hgid, "\n", sep=""))
        cat(        "\tMaintainers .............: Havard Rue <hrue@math.ntnu.no>\n")
        cat(        "\t                         : Finn Lindgren <finn.lindgren@gmail.com>\n")
        cat(        "\t                         : Daniel Simpson <dp.simpson@gmail.com>\n")
        cat(        "\t                         : Andrea Riebler <andrea.riebler@math.ntnu.no>\n")
        cat(        "\t                         : Elias Teixeira Krainski <elias.krainski@math.ntnu.no>\n")
        cat(        "\t                         : Geir-Arne Fuglstad <fulgstad@math.ntnu.no>\n")
        cat(        "\tWeb-page ................: www.r-inla.org\n")
        cat(        "\tEmail support ...........: help@r-inla.org\n")
        cat(        "\t                         : r-inla-discussion-group@googlegroups.com\n")
        cat(        "\tSource-code .............: bitbucket.org/hrue/r-inla\n")
        cat("\n")

        return(invisible())

    } else if (what %in% c("hgid", "rinla")) {
        return (rinla.hgid)
    } else if (what %in% "inla") {
        return (inla.hgid)
    } else if (what %in% "date") {
        return (date) 
    } else if (what %in% "bdate") {
        return (bdate) 
    } else if (what %in% "version") {
        return (version) 
    }
 
    stop("This should not happen.")
}
