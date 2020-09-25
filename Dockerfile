FROM rocker/tidyverse

# install R package dependencies
RUN apt-get update -qq --allow-releaseinfo-change \
    && apt-get -y --no-install-recommends install \
        libpoppler-cpp-dev \
        poppler-utils \
        libmagick++-dev

RUN install2.r --error \
    jsonlite \
    furrr \
    pdftools \
    urltools \
    fuzzyjoin \
    magick \
    fs \
    tensorflow \
    keras

# add locale
RUN locale-gen pt_BR \
  && locale-gen pt_BR.UTF-8 \
  && update-locale

ENV WORKON_HOME /opt/virtualenvs
ENV PYTHON_VENV_PATH $WORKON_HOME/r-tensorflow

## Set up a user modifyable python3 environment
RUN apt update --allow-releaseinfo-change && apt install -y --no-install-recommends \
        libpython3-dev \
        python3-venv && \
    rm -rf /var/lib/apt/lists/*

RUN python3 -m venv ${PYTHON_VENV_PATH}

ENV PATH ${PYTHON_VENV_PATH}/bin:${PATH}
RUN echo "PATH=${PATH}" >> /usr/local/lib/R/etc/Renviron && \
    echo "WORKON_HOME=${WORKON_HOME}" >> /usr/local/lib/R/etc/Renviron && \
    echo "RETICULATE_PYTHON_ENV=${PYTHON_VENV_PATH}" >> /usr/local/lib/R/etc/Renviron

## Because reticulate hardwires these PATHs...
RUN ln -s ${PYTHON_VENV_PATH}/bin/pip /usr/local/bin/pip && \
    ln -s ${PYTHON_VENV_PATH}/bin/virtualenv /usr/local/bin/virtualenv

RUN Rscript -e "keras::install_keras()"

### CHANGE ONCE PR IS ACCEPTED
RUN installGithub.r \
    abjur/abjutils \
    decryptr/decryptr \
    && rm -rf /tmp/downloaded_packages/
