# ripinclude
Create individual PDFs from \include{} in LatTeX

Written many years ago...

super useful e.g. for NSF grants where you have to create a TON of
individual files, e.g.


\documentclass[11pt,letterpaper]{article}
% Header stuff...
\begin{document}
\include{summary}
\include{main}
\include{refs}
\include{admin/facilities}
\include{admin/dmp} 
\end{document}

With a file like this, you'll get

PDFs/summary.pdf
PDFs/main.pdf
PDFs/refs.pdf
PDFs/admin_facilities.pdf
PDFs/admin_dmp.pdf


