# SPDX-License-Identifier: Apache-2.0
# SPDX-FileCopyrightText: Copyright (c) 2026 Ainekko, Co.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

from http.server import HTTPServer, SimpleHTTPRequestHandler
import os
import re


class MDServe(SimpleHTTPRequestHandler):
    def do_GET(self):
        print(os.getcwd())
        print(f" DOGET {self.requestline} {self.path}")
        # if re.search('\S//mdwiki.html',self.path):
        if re.search('//mdwiki.html',self.path):
                loc="/mdwiki.html"
                print(f"redirecting{self.path} to {loc}")
                self.send_response(301)
                self.send_header("Location", loc)
                self.end_headers()


        paths = []
        (p, ext) = os.path.splitext(self.path)
        p = os.path.normpath(p)
        print(f"{p},{ext}")
        if ext != "" and os.path.exists("".join([os.getcwd(), self.path])):
            SimpleHTTPRequestHandler.do_GET(self)
        elif ext=="" or ext==".md":
            paths.append(f"{p}.md")
            paths.append(f"{p}/index.md")
            print(paths)
        for p in paths:
            path = "".join([os.getcwd(), p])
            print(f"checking{path}")
            if os.path.exists(path):
                x = p.lstrip("/")
                loc=f"/mdwiki.html#!{x}"
                print(f"redirecting {loc}")
                self.send_response(301)
                self.send_header("Location", loc)
                self.end_headers()
                # self.path=p
                # print(f"sending {self.path}")
                # self.send_response(200)
                # if ext==".html":
                #     self.send_header('Content-type', 'text/html')
                # else:
                #     self.send_header('Content-type', 'text/markdown')
                # # self.send_header('Content-Disposition', 'attachment; filename="file.pdf"')
                # self.end_headers()
                # with open(path,'rb') as x:
                #     self.wfile.write(x.read())
                # break

        else:
            print(f"Path not found  {self.path}")
            SimpleHTTPRequestHandler.do_GET(self)


def run(server_class=HTTPServer, handler_class=SimpleHTTPRequestHandler):
    server_address = ("", 8001)
    httpd = server_class(server_address, handler_class)
    httpd.serve_forever()


if __name__ == "__main__":
    run(handler_class=MDServe)
