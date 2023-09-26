(lang dune 3.9)
(formatting
 (enabled_for ocaml))

(using melange 0.1)

(name server-reason-react-example)

(generate_opam_files true)

(source
 (github joprice/server-reason-react-example))

(authors "pricejosephd@gmail.com")
(maintainers "pricejosephd@gmail.com")
(license MIT)

(package
 (name server-reason-react-example)
 (synopsis "A short synopsis")
 (description "A longer description")
 (depends ocaml dune)
 (tags
  (topics "to describe" your project)))

