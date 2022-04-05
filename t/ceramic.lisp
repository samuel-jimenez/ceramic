(in-package :cl-user)
(defpackage ceramic-test
  (:use :cl :fiveam)
  (:import-from :ceramic.file
                :*ceramic-directory*
                :wipe-data)
  (:export :run-tests))
(in-package :ceramic-test)

(defun run-tests ()
  (let* ((*ceramic-directory* (asdf:system-relative-pathname :ceramic-test
                                                             #p"t/ceramic/"))
         (ceramic.log:*logging* t))
    (run! 'ceramic-test.resource:resource)
    (run! 'ceramic-test.setup:setup)
    (run! 'ceramic-test.driver:driver)
    (run! 'ceramic-test.window:window)
    #-win32 (run! 'ceramic-test.crashreporter:crashreporter); this fails following tests for windows
    (run! 'ceramic-test.dialog:dialog)
    (run! 'ceramic-test.integration:integration)
    (run! 'ceramic-test.misc:misc)
    ;; Cleanup
    (ceramic.file:wipe-data)))
