# TexLiveのレポジトリをダウンロードしてからビルドする場合

FROM rocker/rstudio:latest as builder
COPY ./texlive/tlnet /texlive/tlnet
WORKDIR /texlive/tlnet
RUN printf  "%s\n" \
            "TEXDIR  /usr/local/texlive" \
            "selected_scheme scheme-full" \
            "option_doc 0" \
            "option_src 0" \
        > ./texlive.profile

RUN ./install-tl \
        --profile ./texlive.profile

# TexLiveをインターネットから直接インストールする場合
# ↑のコードを削除して，↓のコードのコメントを外す

#  FROM rocker/rstudio:latest as builder
#  WORKDIR /work
#  RUN cd /work && mkdir install-tl-unx && \
#      wget -qO- https://mirror.ctan.org/systems/texlive/tlnet/install-tl-unx.tar.gz | \
#      tar -xz -C ./install-tl-unx --strip-components=1 && \
#      printf "%s\n" \
#        "TEXDIR  /usr/local/texlive" \
#        "selected_scheme scheme-full" \
#        "option_doc 0" \
#        "option_src 0" \
#        > ./install-tl-unx/texlive.profile
#  
#  RUN ./install-tl-unx/install-tl \
#        --profile ./install-tl-unx/texlive.profile

FROM rocker/rstudio:latest
COPY --from=builder /usr/local/texlive /usr/local/texlive
ARG TARGETARCH

WORKDIR /work

# 必要なパッケージのインストール
RUN apt update && apt upgrade -y &&  \
    apt install -y \
      wget curl gnupg perl-modules openssh-client libnuma-dev \
      ghostscript gnuplot pdf2svg librsvg2-bin libcairo2-dev \
      fontconfig fonts-ipafont fonts-ipaexfont fonts-noto-cjk\
      libfontconfig1-dev libharfbuzz-dev libfribidi-dev \
      libxt6 libudunits2-dev libproj-dev libgdal-dev \
      python3 python3-pip && \
    apt autoremove -y && \
    apt clean && \
    rm -rf /var/lib/apt/lists/*

## github copilot
RUN echo "copilot-enabled=1" > /etc/rstudio/rsession.conf
# Renvのインストール
RUN R -e "install.packages(c('renv'))"

# .pipフォルダにパスを通す
ENV PATH $PATH:/home/rstudio/.pip/bin

# TeX Liveのインストール
RUN /usr/local/texlive/bin/*/tlmgr path add

# gnuplot-lua-tikz.sty
RUN mkdir /usr/local/texlive/texmf-local/tex/latex/gnuplot && \
    cd /usr/local/texlive/texmf-local/tex/latex/gnuplot && \
    gnuplot -e "set term tikz createstyle" && \
    mktexlsr

# Pandocフィルターのインストール
## pandoc-crossref
RUN wget https://github.com/lierdakil/pandoc-crossref/releases/download/v0.3.17.1/pandoc-crossref-Linux.tar.xz && \
    tar -xf pandoc-crossref-Linux.tar.xz && \
    mv pandoc-crossref /usr/bin
## pandoc-plot
RUN pip3 install gdown
RUN PPFILE=$( \
      case ${TARGETARCH} in \
        amd64 ) echo "https://drive.google.com/uc?id=14oOMOrwPgIgaZ8LaWq0RRWS1UhpBF6NW";; \
        arm64 ) echo "https://drive.google.com/uc?id=1DzG92fRrOf8UBNyMgKz0L7yy1cbVIyXp";; \
      esac \
    ) && \
    gdown ${PPFILE} && \
    mv pandoc-plot /usr/bin && \
    chmod 755 /usr/bin/pandoc-plot
RUN rm -rf *
