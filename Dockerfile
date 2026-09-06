# Assisted Linux Labs — immagine da Alpine Linux (musl); tag 3.24 (minor series) pinnato.
# L'obiettivo e' un'immagine piu' piccola e veloce di Ubuntu, mantenendo la
# stessa esperienza: CLI, 9 lab, man page localizzate.

# ---- Stadio "mans": estrae le man page EN + IT ----
# Su Alpine il pacchetto man-pages contiene solo ~18 pagine e manpages-it non
# esiste come pacchetto (ne' in Ubuntu moderne, che lo forniscono come stub
# vuoto). Debian bookworm ha sia i man per i comandi del corso sia la
# traduzione italiana: installiamo gli stessi tool del finale e copiamo
# /usr/share/man come file statici. Il container slim esclude /usr/share/man
# via dpkg (path-exclude): lo disattiviamo per estrarre le pagine.
FROM debian:bookworm-slim AS mans
RUN sed -i '/path-exclude/s/^/#/' /etc/dpkg/dpkg.cfg.d/docker \
 && apt-get update \
 && apt-get install -y --no-install-recommends --reinstall \
    coreutils findutils grep gawk sed tar procps passwd login sudo util-linux bash less \
    openssh-client iproute2 iputils-ping nano rsync curl tree manpages manpages-it \
 && rm -rf /var/lib/apt/lists/*

# ---- Stadio finale: Alpine ----
FROM alpine:3.24

# Modalita di apprendimento: standard (default), arcade, hardcade.
ARG LAB_MODE=standard

# Variabili d'ambiente: percorso lab, PATH e locale UTF-8.
# LAB_MODE qui e' l'ARG sopra promosso a ENV: resta leggibile a runtime.
# Sulla libc musl il default e' gia' UTF-8-aware, ma LANG/LC_ALL espliciti
# (musl-locales) rendono stabile ogni misurazione (es. wc -m del banner).
ENV LAB_ROOT=/opt/assisted-labs \
    LAB_MODE=${LAB_MODE} \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    PATH=/opt/assisted-labs/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# Tool del corso: implementazioni GNU dove i lab dipendono da esse, piu' i
# comandi di sistema (shadow per useradd/usermod, openrc per lab 08).
# busybox copre il resto (crontab, syslogd, logger, logread, df, du, cmp...).
RUN apk add --no-cache \
      bash \
      bash-completion \
      ca-certificates \
      coreutils \
      curl \
      diffutils \
      findutils \
      gawk \
      grep \
      iproute2 \
      iputils \
      less \
      man-db \
      man-pages \
      musl-locales \
      nano \
      netcat-openbsd \
      openrc \
      openssh-client \
      procps \
      rsync \
      sed \
      shadow \
      sudo \
      tar \
      tree \
 && rm -rf /var/cache/apk/*

# Le man page EN + IT arrivano dallo stadio mans e vengono indicizzate con mandb.
# Attenzione: il COPY si MERGE sovrascrivendo /usr/share/man, quindi le pagine
# Debian (2400+) SOSTITUISCONO quelle del pacchetto man-pages di Alpine.
COPY --from=mans /usr/share/man /usr/share/man
RUN mandb -c >/dev/null 2>&1 || true

# Lab ufficiali: SOLO in immagine. Il volume monta /workspace per i file di lavoro.
COPY bin/lab /opt/assisted-labs/bin/lab
COPY bin/intro.sh /opt/assisted-labs/bin/intro.sh
COPY lib/ /opt/assisted-labs/lib/
COPY labs/ /opt/assisted-labs/labs/
COPY contexto/ /opt/assisted-labs/contexto/
COPY tests/ /opt/assisted-labs/tests/
COPY README.md /opt/assisted-labs/README.md

# Configurazione shell di sistema: banner di benvenuto e completamento tab di 'lab'.
COPY startup-banner.sh /etc/profile.d/assisted-labs.sh
COPY bin/lab-completion.bash /etc/bash_completion.d/lab

# Rendi eseguibili i tool del lab e crea il symlink 'lab' nel PATH di sistema
# (eseguito DOPO i COPY; i file dei lab sono gia' eseguibili ma per sicurezza).
RUN chmod +x /opt/assisted-labs/bin/lab \
 && chmod +x /opt/assisted-labs/bin/intro.sh \
 && find /opt/assisted-labs/labs -name '*.sh' -exec chmod +x {} + \
 && ln -sfn /opt/assisted-labs/bin/lab /usr/local/bin/lab \
 && printf '%%wheel ALL=(ALL) ALL\n' > /etc/sudoers.d/wheel \
 && chmod 440 /etc/sudoers.d/wheel

# Area di lavoro dei lab + caricamento del banner nelle shell interattive.
# Su Alpine bash legge /etc/bash/bashrc (non /etc/bash.bashrc).
RUN mkdir -p /workspace/training \
 && printf '\n# Assisted Linux Labs\nif [ -f /etc/profile.d/assisted-labs.sh ]; then . /etc/profile.d/assisted-labs.sh; fi\n' >> /etc/bash/bashrc

# Directory di lavoro predefinita: il volume host monta qui /workspace.
WORKDIR /workspace
# Shell di default per chi entra nel container senza comandi.
CMD ["bash"]