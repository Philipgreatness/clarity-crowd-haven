;; CrowdHaven Insurance Pool Contract

;; Constants
(define-constant contract-owner tx-sender)
(define-constant ERR-NOT-AUTHORIZED (err u101))
(define-constant ERR-POOL-NOT-FOUND (err u102))
(define-constant ERR-INSUFFICIENT-FUNDS (err u103))
(define-constant ERR-INVALID-AMOUNT (err u104))
(define-constant ERR-CLAIM-NOT-FOUND (err u105))

;; Data structures
(define-map pools
  { pool-id: uint }
  {
    name: (string-ascii 64),
    creator: principal,
    total-staked: uint,
    member-count: uint,
    active: bool
  }
)

(define-map pool-members
  { pool-id: uint, member: principal }
  { staked-amount: uint }
)

(define-map claims 
  { claim-id: uint }
  {
    pool-id: uint,
    claimant: principal,
    amount: uint,
    description: (string-ascii 256),
    approved-votes: uint,
    rejected-votes: uint,
    status: (string-ascii 20)
  }
)

;; Pool creation and management
(define-public (create-pool (name (string-ascii 64)))
  (let ((pool-id (+ (var-get next-pool-id) u1)))
    ;; Implementation
  )
)

(define-public (join-pool (pool-id uint) (stake-amount uint))
  (let (
    (pool (unwrap! (map-get? pools {pool-id: pool-id}) (err ERR-POOL-NOT-FOUND)))
  )
    ;; Implementation
  )
)

;; Claims handling
(define-public (submit-claim 
  (pool-id uint) 
  (amount uint)
  (description (string-ascii 256))
)
  (let ((claim-id (+ (var-get next-claim-id) u1)))
    ;; Implementation
  )
)

(define-public (vote-on-claim (claim-id uint) (approve bool))
  (let (
    (claim (unwrap! (map-get? claims {claim-id: claim-id}) (err ERR-CLAIM-NOT-FOUND)))
  )
    ;; Implementation
  )
)

;; Read only functions
(define-read-only (get-pool-info (pool-id uint))
  (ok (map-get? pools {pool-id: pool-id}))
)

(define-read-only (get-claim-info (claim-id uint))
  (ok (map-get? claims {claim-id: claim-id}))
)
