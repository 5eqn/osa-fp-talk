// color profiles
#let colors = (
  gray: luma(238),
  blue: rgb(240, 240, 250),
)

#let tag(body, color: "gray") = {
  set text(font: ("Noto Sans CJK SC"), 10pt)
  box(
     fill: colors.at(color),
     inset: (x: 3pt, y: 0pt),
     outset: (y: 3pt),
     radius: 2pt,
     body
  )
}

#let sect(body, color: "gray", title: "") = {
  if title == "" {
    box(
      width: 100%,
      fill: colors.at(color),
      radius: 3pt,
      inset: 1em,
      body
    )
  } else {
    set heading(numbering: none, outlined: false, supplement: "Box")
    box(
      width: 100%,
      fill: colors.at(color),
      radius: 3pt,
      inset: 1em,
    )[
      === #title
      #body
    ]
  }
}

#let project(
  title: "",
  authors: (),
  body,
) = {
  set document(author: authors, title: title)
  set page(numbering: "1", number-align: center)
  set text(font: ("Noto Serif CJK SC"))

  align(center)[
    #block(text(weight: 700, 1.75em, title))
    #v(1em, weak: true)
  ]

  pad(
    top: 0.5em,
    bottom: 0.5em,
    x: 2em,
    grid(
      columns: (1fr,) * calc.min(3, authors.len()),
      gutter: 1em,
      ..authors.map(author => align(center, strong(author))),
    ),
  )

  set par(justify: true, leading: 0.75em)

  show heading: it => {
    set block(above: 1em, below: 1em)
    it
  }

  body
}
