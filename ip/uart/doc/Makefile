title=uart IP
client=TBD Client Name
docstatus=Working Document
document-sha=$(shell git rev-parse --short HEAD )
authoremail=jvs@dyumnin.com
registerfile=uart.md refman.md ai.md
variables=-V title:"$(title)" -V client:"$(client)" -Vauthoremail:$(authoremail) -V document-sha:$(document-sha) -V status:"$(docstatus)"
doc:
	pandoc -F pandoc-imagine $(variables) -o reference_manual.pdf -s --template=$(HOME)/.pandoc/template/dyu/refman.template $(files)  ai.md
