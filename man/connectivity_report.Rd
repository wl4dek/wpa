% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/connectivity_report.R
\name{connectivity_report}
\alias{connectivity_report}
\title{Generate a Connectivity report in HTML}
\usage{
connectivity_report(
  data,
  hrvar = "LevelDesignation",
  mingroup = 5,
  path = "connectivity report",
  timestamp = TRUE
)
}
\arguments{
\item{data}{A Standard Query dataset in the form of a data frame.}

\item{hrvar}{HR Variable by which to split metrics, defaults to "Organization"
but accepts any character vector, e.g. "LevelDesignation"}

\item{mingroup}{Numeric value setting the privacy threshold / minimum group size. Defaults to 5.}

\item{path}{Pass the file path and the desired file name, \emph{excluding the file extension}.
For example, "collaboration report".}

\item{timestamp}{Logical vector specifying whether to include a timestamp in the file name.
Defaults to TRUE.}
}
\description{
The function generates an interactive HTML report using
Standard Query data as an input. The report contains a series
of summary analysis and visualisations relating to key \strong{connectivity}
metrics in Workplace Analytics, including external/internal network size
vs breadth.
}
\seealso{
Other Reports: 
\code{\link{IV_report}()},
\code{\link{capacity_report}()},
\code{\link{coaching_report}()},
\code{\link{collaboration_report}()},
\code{\link{generate_report}()},
\code{\link{validation_report}()}
}
\concept{Reports}
