# batchtopcons.R written by Simon Parker and usable under an MIT license. Interacts with the TOPCONS web server
# at https://topcons.net/pred/. Citation for the TOPCONS web server: TOPCONS: The TOPCONS web server for combined
# membrane protein topology and signal peptide prediction. Tsirigos KD, Peters C, Shu N, Käll L and Elofsson A (2015)
# Nucleic Acids Research 43 (Webserver issue), W401-W407.

if(!require(glue)) install.packages("glue"); library(glue)
if(!require(stringr)) install.packages("stringr"); library(stringr)

#' Download the TOPCONS batch_wsdl.py file for use by batchcons functions.
#' @param topcons.script.dir The directory which the topcons script will be written to.
downloadTOPCONSScript <- function(topcons.script.dir)
{
  if(missing(topcons.script.dir)) { stop("You must specify an existing directory for your download.")
  } else if(!file.exists(topcons.script.dir)) stop("The specified download directory does not exist.")
  download.file(url = "https://topcons.net/static/download/script/topcons2_wsdl.py",
                destfile = file.path(topcons.script.dir,"batch_wsdl.py"))
}

#' Update the batch_wsdl.py file
#' @description Fixes the url.lib error encountered when your Python installation dates from after the Python urllib
#' package was separated into multiple packages.
#' @param topcons.wsdl.path A file path that leads to the batch_wsdl.py file.
updateTOPCONSScript <- function(topcons.wsdl.path)
{
  if(missing(topcons.wsdl.path)) { stop("You must specify a valid path for batch_wsdl.py.")
  } else if(!file.exists(topcons.wsdl.path)) stop("The specified batch_wsdl.py file does not exist.")
  readLines(topcons.wsdl.path) %>%
    stringr::str_replace("urllib", "urllib.request") %>%
    writeLines(topcons.wsdl.path)
  message("TOPCONS script updated to use urllib.request instead of urllib.")
}

#' Submit a FASTA file to the TOPCONS2 web server.
#' @usage submitTOPCONS(python.path, topcons.wsdl.path, fasta.path, job.name, email.address)
#' @param python.path A file path that leads to a Python exe.
#' @param topcons.wsdl.path A file path that leads to the topcons2_wsdl.py file.
#' @param fasta.path A file path leading to your input FASTA file.
#' Asterisks will be removed by the TOPCONS web server.
#' @param job.name A job name for this submission, e.g. 'batchtopcons_TEST'
#' @param email.address An email address which the TOPCONS web server will
#' send an email to once the job is finished.
submitTOPCONS <- function(python.path, topcons.wsdl.path, fasta.path, job.name = NA_character_, email.address = NA_character_)
{
  if(missing(python.path)) stop("You're missing a file path to a Python exe.")
  if(!file.exists(python.path)) stop("The path to your Python exe is invalid.")
  if(missing(topcons.wsdl.path)) stop("You're missing a path to topcons2_wsdl.py. If you do not have it, download from https://topcons.cbr.su.se/static/download/script/topcons2_wsdl.py")
  if(!file.exists(topcons.wsdl.path)) stop("The path to topcons2_wsdl.py is invalid.")
  if(missing(fasta.path)) stop("You must provide a directory to save the TOPCONS results to.")
  if(!file.exists(fasta.path)) stop("The path to your FASTA file is invalid.")
  if(is.na(job.name)) { message("This TOPCONS submission will have no job name.") ; job.name <- ""
  } else message(glue("This TOPCONS job has the name {job.name}."))
  if(is.na(email.address)) { message("A reminder email will not be sent once this job is finished.") ; email.address <- ""
  } else message(glue("A reminder email will be sent to {email.address} once this job is completed."))

  if(job.name == "" & email.address == "") { submit_cmd <- glue('"{normalizePath(python.path)}" "{normalizePath(topcons.wsdl.path)}" -m submit -seq "{normalizePath(fasta.path)}"')
  } else if(job.name != "" & email.address == "") { submit_cmd <- glue('"{normalizePath(python.path)}" "{normalizePath(topcons.wsdl.path)}" -m submit -seq "{normalizePath(fasta.path)}" -jobname {job.name}')
  } else if(job.name == "" & email.address != "") { submit_cmd <- glue('"{normalizePath(python.path)}" "{normalizePath(topcons.wsdl.path)}" -m submit -seq "{normalizePath(fasta.path)}" -email {email.address}')
  } else { submit_cmd <- glue('"{normalizePath(python.path)}" "{normalizePath(topcons.wsdl.path)}" -m submit -seq "{normalizePath(fasta.path)}" -jobname {job.name} -email {email.address}') }

  sys_output <- system(submit_cmd)
  print(sys_output)
}

#' Fetch TOPCONS results from the TOPCONS web server.
#' @param python.path A file path that leads to a Python exe.
#' @param topcons.wsdl.path A file path that leads to the topcons2_wsdl.py file.
#' @param output.dir The directory to download your TOPCONS output to.
#' @param job.id The job ID of the submission you're retrieving, e.g. 'rst_12TEST34'
#' @param extract.results Should the query.results.txt file be extracted from the downloaded zipped folder? If set to
#' TRUE, the zipped folder will NOT be deleted.
fetchTOPCONS <- function(python.path, topcons.wsdl.path, output.dir, job.id, extract.results = FALSE)
{
  if(missing(python.path)) stop("You must supply a file path to a Python exe.")
  if(!file.exists(python.path)) stop("The path to your Python exe is invalid.")
  if(missing(topcons.wsdl.path)) stop("You must provide a path to topcons2_wsdl.py. If you do not have it, download from https://topcons.cbr.su.se/static/download/script/topcons2_wsdl.py")
  if(!file.exists(topcons.wsdl.path)) stop("The path to topcons2_wsdl.py is invalid.")
  if(missing(output.dir)) stop("You must provide a directory to save the TOPCONS results to.")
  if(!file.exists(output.dir)) stop("The specified output directory does not exist.")
  if(missing(job.id)) stop("You must provide a job ID when fetching TOPCONS results.")

  fetch_cmd <- glue('"{normalizePath(python.path)}" "{normalizePath(topcons.wsdl.path)}" -m get -jobid {job.id} -outpath "{normalizePath(output.dir)}"')
  sys_output <- system(fetch_cmd, intern = TRUE)
  print(glue("Command line output: {sys_output}"))
  zip_path <- file.path(output.dir, glue("{job.id}.zip"))
  if(file.exists(zip_path))
  {
    if(extract.results) { extractQueryResult(output.dir, job.id, remove.zip = FALSE)
    } else message(glue("TOPCONS zipped folder in {file.path(output.dir)}"))
  } else stop("Either check that an urllib error has not occurred, or wait for your TOPCONS job to finish running.")
}

#' Extract the query.result.txt file from a directory with a given TOPCONS zip file.
#'
#' @param zipdir.path A file path leading to the directory containing your TOPCONS zip file. The text file will be
#' extracted to this directory.
#' @param job.id A TOPCONS job ID.
#' @param remove.zip A boolean value denoting whether you want the zipped folder to be deleted after query.result.txt
#' is extracted. Defaults to FALSE.
extractQueryResults <- function(zipdir.path, job.id, remove.zip = FALSE)
{
  if(missing(zipdir.path)) stop("You must supply a file path to your TOPCONS zip file.")
  if(!file.exists(zipdir.path)) stop("The specified zip file does not exist.")
  if(missing(job.id)) stop("You must provide a job ID. This will be in the format.")

  # Unzip the file
  zip_file_path <- file.path(zipdir.path, glue("{job.id}.zip"))
  query_result_path <- file.path(job.id,"query.result.txt")
  utils::unzip(zipfile = zip_file_path,
               files = query_result_path,
               exdir = zipdir.path)
  # Move and rename the file, then delete the directory created by utils::unzip
  txtfile_path <- file.path(zipdir.path, query_result_path)
  new_location_path <- file.path(zipdir.path, glue("{job.id}.query.result.txt"))
  file.copy(txtfile_path, new_location_path)
  unlink(file.path(zipdir.path, job.id), recursive = TRUE)
  # Delete the zipped folder if specified by the user
  if(remove.zip) file.remove(zip_file_path)
  message(glue("Query results fetched and placed in {zipdir.path}"))
}

#' Download query results directly
#'
#' @details Note that job results are only available for 30 days after the job was run. This function cuts
#' down on the amount of extra data (images, HTML files etc.) included in the zipped folder for a given job.
#' @param output.dir The directory to which you want the text file downloaded.
#' @param job.id The TOPCONS job ID for which you want the results.
downloadQueryResults <- function(output.dir, job.id)
{
  if(missing(output.dir)) { stop("You must specify the directory to which the txt file will be downloaded.")
  } else if(!file.exists(output.dir)) stop("The specified download directory does not exist.")
  if(missing(job.id)) stop("You must specify a TOPCONS job ID.")

  job_url <- glue("https://topcons.net/static/result/{job.id}/{job.id}/query.result.txt")
  dest_file <- file.path(output.dir, "query.result.txt")
  download.file(url = job_url,
                destfile = dest_file)
  file.rename(dest_file, file.path(output.dir, glue("{trimws(job.id)}.query.result.txt")))
}
