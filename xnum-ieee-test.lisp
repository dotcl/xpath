;;; -*- show-trailing-whitespace: t; indent-tabs-mode: nil -*-

;;; Copyright (c) 2007,2008 Ivan Shvedunov. All rights reserved.
;;; Copyright (c) 2003-2008 David Lichteblau <david@lichteblau.com>

;;; Redistribution and use in source and binary forms, with or without
;;; modification, are permitted provided that the following conditions
;;; are met:
;;;
;;;   * Redistributions of source code must retain the above copyright
;;;     notice, this list of conditions and the following disclaimer.
;;;
;;;   * Redistributions in binary form must reproduce the above
;;;     copyright notice, this list of conditions and the following
;;;     disclaimer in the documentation and/or other materials
;;;     provided with the distribution.
;;;
;;; THIS SOFTWARE IS PROVIDED BY THE AUTHOR 'AS IS' AND ANY EXPRESSED
;;; OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
;;; WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
;;; ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY
;;; DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
;;; DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE
;;; GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
;;; INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
;;; WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
;;; NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
;;; SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

(in-package :xpath-test)

(eval-when (:compile-toplevel :load-toplevel :execute)
  (defparameter +positive-infinity+
    #+sbcl sb-ext:double-float-positive-infinity
    #+dotcl dotcl:double-float-positive-infinity)
  (defparameter +negative-infinity+
    #+sbcl sb-ext:double-float-negative-infinity
    #+dotcl dotcl:double-float-negative-infinity))

;; TODO: converting to string
(deftest test-xnum
  (with-float-traps-masked ()
    (assert* (xnum-p 1)
	     (xnum-p -1d0)
	     (xnum-p 3/5)
	     (xnum-p #.+positive-infinity+)
	     (xnum-p #.+negative-infinity+)
	     (xnum-p +nan+)
	     (compare-numbers 'equal #.+positive-infinity+ #.+positive-infinity+)
	     (compare-numbers 'equal #.+negative-infinity+ #.+negative-infinity+)
	     (compare-numbers '< #.+negative-infinity+ #.+positive-infinity+)
	     (compare-numbers '<= #.+negative-infinity+ #.+positive-infinity+)
	     (compare-numbers '> #.+positive-infinity+ #.+negative-infinity+)
	     (compare-numbers '>= #.+positive-infinity+ #.+negative-infinity+)
	     (compare-numbers '< #.+negative-infinity+ 42)
	     (compare-numbers '> #.+positive-infinity+ 42)
	     (compare-numbers '<= #.+negative-infinity+ 42)
	     (compare-numbers '>= #.+positive-infinity+ 42)
	     (compare-numbers 'equal 1/10000 0.0001d0))
    (loop for op in '(equal < > <= >=)
          do (assert* (not (compare-numbers op +nan+ +nan+))
		      (not (compare-numbers op +nan+ #.+positive-infinity+))
		      (not (compare-numbers op #.+positive-infinity+ +nan+))
		      (not (compare-numbers op +nan+ #.+negative-infinity+))
		      (not (compare-numbers op #.+negative-infinity+ +nan+))
		      (not (compare-numbers op +nan+ 42))
		      (not (compare-numbers op +nan+ -42))
		      (not (compare-numbers op 42 +nan+))
		      (not (compare-numbers op +nan+ "34"))))
    (assert-float-equal* 42 (parse-xnum "42") ;; FIXME: double-float?
			 -1 (parse-xnum "-1")
			 5 (parse-xnum "   5  ")
			 +nan+ (parse-xnum "abc")
			 +nan+ (parse-xnum ""))
    (assert (< (abs (- 2.3d2 (parse-xnum "  2.3e+2  "))) 1e-7)) ;; FIXME
    (assert-float-equal* #.+positive-infinity+ (xnum-/ 1 0d0)
			 #.+negative-infinity+ (xnum-/ -1 0)
			 0 (xnum-/ 42 #.+positive-infinity+)
			 0 (xnum-/ 42d0 #.+negative-infinity+)
			 42 (xnum-/ 84 2)
			 +nan+ (xnum-/ 0 0)
			 +nan+ (xnum-/ #.+positive-infinity+ #.+positive-infinity+)
			 +nan+ (xnum-/ #.+negative-infinity+ #.+negative-infinity+)
			 +nan+ (xnum-/ #.+negative-infinity+ #.+positive-infinity+)
			 +nan+ (xnum-/ #.+positive-infinity+ #.+negative-infinity+)
			 42 (xnum-* 21 2)
			 0 (xnum-* 0 0)
			 #.+positive-infinity+ (xnum-* #.+positive-infinity+ 42)
			 #.+positive-infinity+ (xnum-* 42 #.+positive-infinity+)
			 #.+positive-infinity+ (xnum-* #.+positive-infinity+ #.+positive-infinity+)
			 #.+positive-infinity+ (xnum-* #.+negative-infinity+ #.+negative-infinity+)
			 #.+negative-infinity+ (xnum-* #.+negative-infinity+ #.+positive-infinity+)
			 #.+negative-infinity+ (xnum-* 42 #.+negative-infinity+)
			 #.+negative-infinity+ (xnum-* #.+negative-infinity+ 42)
			 +nan+ (xnum-* 0 #.+positive-infinity+)
			 +nan+ (xnum-* 0 #.+negative-infinity+)
			 +nan+ (xnum-* #.+positive-infinity+ 0)
			 +nan+ (xnum-* #.+negative-infinity+ 0)
			 +nan+ (xnum-* 0 #.+positive-infinity+)
			 +nan+ (xnum-* 0 #.+negative-infinity+)
			 42 (xnum-+ 20 22)
			 #.+positive-infinity+ (xnum-+ #.+positive-infinity+ #.+positive-infinity+)
			 #.+positive-infinity+ (xnum-+ 42 #.+positive-infinity+)
			 #.+positive-infinity+ (xnum-+ #.+positive-infinity+ 42)
			 #.+negative-infinity+ (xnum-+ 42 #.+negative-infinity+)
			 #.+negative-infinity+ (xnum-+ #.+negative-infinity+ 42)
			 #.+negative-infinity+ (xnum-+ #.+negative-infinity+ #.+negative-infinity+)
			 +nan+ (xnum-+ #.+negative-infinity+ #.+positive-infinity+)
			 +nan+ (xnum-+ #.+positive-infinity+ #.+negative-infinity+)
			 -42 (xnum-- 42)
			 #.+negative-infinity+ (xnum-- #.+positive-infinity+)
			 #.+positive-infinity+ (xnum-- #.+negative-infinity+)
			 42 (xnum-- 100 58)
			 #.+positive-infinity+ (xnum-- 1 #.+negative-infinity+)
			 #.+positive-infinity+ (xnum-- #.+positive-infinity+ 1)
			 #.+negative-infinity+ (xnum-- #.+negative-infinity+ 1)
			 #.+negative-infinity+ (xnum-- 1 #.+positive-infinity+)
			 +nan+ (xnum-- #.+positive-infinity+ #.+positive-infinity+)
			 +nan+ (xnum-- #.+negative-infinity+ #.+negative-infinity+)
			 +nan+ (xnum-- +nan+)
			 42 (xnum-mod 142 100)
			 42 (xnum-mod 42 #.+positive-infinity+)
			 42 (xnum-mod 42 #.+negative-infinity+)
			 -42 (xnum-mod -42 #.+positive-infinity+)
			 -42 (xnum-mod -42 #.+negative-infinity+)
			 +nan+ (xnum-mod #.+positive-infinity+ #.+negative-infinity+)
			 +nan+ (xnum-mod #.+negative-infinity+ #.+positive-infinity+)
			 +nan+ (xnum-mod #.+negative-infinity+ 42)
			 +nan+ (xnum-mod #.+positive-infinity+ 42)
			 +nan+ (xnum-mod 0 0)
			 +nan+ (xnum-mod 42 0)
			 2 (xnum-round 1.6)
			 +nan+ (xnum-round +nan+)
			 #.+positive-infinity+ (xnum-round #.+positive-infinity+)
			 #.+negative-infinity+ (xnum-round #.+negative-infinity+)
			 1 (xnum-floor 1.6)
			 +nan+ (xnum-floor +nan+)
			 #.+positive-infinity+ (xnum-floor #.+positive-infinity+)
			 #.+negative-infinity+ (xnum-floor #.+negative-infinity+)
			 2 (xnum-ceiling 1.6)
			 +nan+ (xnum-ceiling +nan+)
			 #.+positive-infinity+ (xnum-ceiling #.+positive-infinity+)
			 #.+negative-infinity+ (xnum-ceiling #.+negative-infinity+))
    (loop for op in '(xnum-/ xnum-* xnum-+ xnum-- xnum-mod)
          do (assert-float-equal*
	      +nan+ (funcall op +nan+ +nan+)
	      +nan+ (funcall op +nan+ 42)
	      +nan+ (funcall op 42 +nan+)))
    (assert-equal* "42" (xnum->string 42)
		   "-42" (xnum->string -42)
		   "NaN" (xnum->string +nan+)
		   "Infinity" (xnum->string #.+positive-infinity+)
		   "-Infinity" (xnum->string #.+negative-infinity+))))
