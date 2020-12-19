FROM alpine:3.12.3

LABEL MAINTAINER "ishibashi.futoshi <ishibashi.futos@outlook.com>"
LABEL DESCRIPTION "Pandoc for Japanese based on Alpine Linux."
LABEL REFERENCE "https://github.com/Kumassy/docker-alpine-pandoc-ja"

# Install Tex Live
ENV TEXLIVE_VERSION 2019
ENV TEXLIVE_REPOGITORY http://ftp.math.utah.edu/pub/tex/historic/systems/texlive/$TEXLIVE_VERSION/tlnet-final/
ENV PATH /usr/local/texlive/$TEXLIVE_VERSION/bin/x86_64-linuxmusl:$PATH

RUN wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub \
 && wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.32-r0/glibc-2.32-r0.apk \
 && apk --no-cache add -q glibc-2.32-r0.apk && rm -f glibc-2.32-r0.apk \
 && apk --no-cache add -q perl xz tar wget fontconfig-dev \
 && mkdir -p /tmp/src/install-tl-unx \
 && wget -qO- $TEXLIVE_REPOGITORY/install-tl-unx.tar.gz | \
    tar -xz -C /tmp/src/install-tl-unx --strip-components=1 \
 && printf "%s\n" \
      "selected_scheme scheme-basic" \
      "option_doc 0" \
      "option_src 0" \
      > /tmp/src/install-tl-unx/texlive.profile \
 && /tmp/src/install-tl-unx/install-tl \
      --profile=/tmp/src/install-tl-unx/texlive.profile \
      --repository=$TEXLIVE_REPOGITORY \
 && tlmgr option repository $TEXLIVE_REPOGITORY \
 && tlmgr update --self && tlmgr update --all \
 && tlmgr install \
      collection-basic collection-latex \
      collection-latexrecommended collection-latexextra \
      collection-fontsrecommended collection-langjapanese latexmk \
      luatexbase ctablestack fontspec luaotfload lualatex-math \
      sourcesanspro sourcecodepro \
 && rm -Rf /tmp/src \
 && apk --no-cache del fontconfig-dev

# Install Pandoc
ENV PANDOC_VERSION 2.11.2
ENV PANDOC_DOWNLOAD_URL https://github.com/jgm/pandoc/archive/${PANDOC_VERSION}.tar.gz
ENV PANDOC_DOWNLOAD_SHA512 9d265941f224d376514e18fc45d5292e9c2481b04693c96917a0d55ed817b190cf2ea2666097388bfdf30023db2628567ea04ff6b9cc3316130a8190da72c605
ENV PANDOC_ROOT /usr/local/pandoc
ENV PATH $PATH:$PANDOC_ROOT/bin

RUN apk --no-cache add -q \
    gmp \
    libffi \
 && apk --no-cache add -q --virtual build-dependencies \
    --repository "http://nl.alpinelinux.org/alpine/edge/community" \
    ghc \
    cabal \
    linux-headers \
    musl-dev \
    zlib-dev \
    curl \
 && mkdir -p /pandoc-build && cd /pandoc-build \
 && curl -fsSL "$PANDOC_DOWNLOAD_URL" -o pandoc.tar.gz \
 && echo "$PANDOC_DOWNLOAD_SHA512  pandoc.tar.gz" sha512sum -c - \
 && tar -xzf pandoc.tar.gz --strip=1 && rm -f pandoc.tar.gz \
 && cabal new-update \
 && cabal install --only-dependencies \
 && cabal configure --prefix=$PANDOC_ROOT \
 && cabal new-build --disable-tests \
 && mkdir -p $PANDOC_ROOT/bin \
 && find dist-newstyle -name 'pandoc*' -type f -perm -u+x \
   -exec strip '{}' ';' \
   -exec cp '{}' ${PANDOC_ROOT}/bin ';' \
 && apk del --purge build-dependencies \
 && rm -Rf /root/.cabal/ /root/.ghc/ \
 && cd / && rm -Rf /pandoc-build

# Install pandoc-crossref
ENV PANDOC_CROSSREF_VERSION v0.3.8.4
RUN wget https://github.com/lierdakil/pandoc-crossref/releases/download/${PANDOC_CROSSREF_VERSION}/pandoc-crossref-Linux.tar.xz -q -O - | tar -Jx \
 && mv pandoc-crossref /usr/bin/ \
 && rm -f pandoc-crossref.1

VOLUME ["/workspace", "/root/.pandoc/templates"]
WORKDIR /workspace
