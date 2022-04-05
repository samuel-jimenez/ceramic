(in-package :cl-user)
(defpackage ceramic-test.integration
  (:use :cl :fiveam)
  (:export :integration))
(in-package :ceramic-test.integration)

(def-suite integration
  :description "Integration tests.")
(in-suite integration)

(defvar *extraction-directory*
  (asdf:system-relative-pathname :ceramic-test-app
                                 #p"extract/"))

(test lifecycle
  (finishes
    (ceramic:start))
  (finishes
    (ceramic:stop)))

(test compiled
  (let* ((app-file (merge-pathnames #p"ceramic-test-app.tar"
                                    *extraction-directory*))
         (binary (merge-pathnames (concatenate 'string
                                          "ceramic-test-app"
                                          #+win32 ".exe")
                                  *extraction-directory*)))
    (ensure-directories-exist app-file)
    (finishes
      (ceramic.bundler:bundle :ceramic-test-app
                              :bundle-pathname app-file))
    (is-true
     (probe-file app-file))
    (finishes
      #-win32 (trivial-extract:extract-tar app-file)
      #+win32 (trivial-extract:extract-zip app-file))
    (is-true
     (probe-file binary))
    (is-true
     (probe-file (merge-pathnames #p"resources/files/file.txt"
                                  *extraction-directory*)))
    (finishes
      (trivial-exe:ensure-executable (merge-pathnames #p"electron/electron"
                                                      *extraction-directory*))
      (trivial-exe:ensure-executable binary))
    (is
     (equal (ceramic.resource:resource-directory 'ceramic-test-app::files)
            (asdf:system-relative-pathname :ceramic-test-app
                                           #p"files/")))
    (is
     (equal (ceramic.resource:resource 'ceramic-test-app::files #p"file.txt")
            (asdf:system-relative-pathname :ceramic-test-app
                                           #p"files/file.txt")))))

(test cleanup
  (uiop:delete-directory-tree *extraction-directory* :validate t))
