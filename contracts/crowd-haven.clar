;; CrowdHaven Insurance Pool Contract

;; Constants
(define-constant contract-owner tx-sender)
(define-constant ERR-NOT-AUTHORIZED (err u101))
(define-constant ERR-POOL-NOT-FOUND (err u102))
(define-constant ERR-INSUFFICIENT-FUNDS (err u103))
(define-constant ERR-INVALID-AMOUNT (err u104))
(define-constant ERR-CLAIM-NOT-FOUND (err u105))
(define-constant ERR-POOL-NOT-ACTIVE (err u106))

;; Data variables
(define-data-var next-pool-id uint u0)
(define-data-var next-claim-id uint u0)

;; Data structures
(define-map pools
  { pool-id: uint }
  {
    name: (string-ascii 64),
    creator: principal,
    total-staked: uint,
    member-count: uint,
    active: bool,
    min-stake: uint
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
(define-public (create-pool (name (string-ascii 64)) (min-stake uint))
  (let ((pool-id (+ (var-get next-pool-id) u1)))
    (var-set next-pool-id pool-id)
    (map-set pools 
      { pool-id: pool-id }
      {
        name: name,
        creator: tx-sender,
        total-staked: u0,
        member-count: u0,
        active: true,
        min-stake: min-stake
      }
    )
    (ok pool-id)
  )
)

(define-public (join-pool (pool-id uint) (stake-amount uint))
  (let (
    (pool (unwrap! (map-get? pools {pool-id: pool-id}) (err ERR-POOL-NOT-FOUND)))
  )
    (asserts! (get active pool) (err ERR-POOL-NOT-ACTIVE))
    (asserts! (>= stake-amount (get min-stake pool)) (err ERR-INVALID-AMOUNT))
    
    (map-set pools
      { pool-id: pool-id }
      (merge pool {
        total-staked: (+ (get total-staked pool) stake-amount),
        member-count: (+ (get member-count pool) u1)
      })
    )
    
    (map-set pool-members
      { pool-id: pool-id, member: tx-sender }
      { staked-amount: stake-amount }
    )
    
    (ok true)
  )
)

;; Claims handling 
(define-public (submit-claim 
  (pool-id uint) 
  (amount uint)
  (description (string-ascii 256))
)
  (let ((claim-id (+ (var-get next-claim-id) u1)))
    (var-set next-claim-id claim-id)
    (map-set claims
      { claim-id: claim-id }
      {
        pool-id: pool-id,
        claimant: tx-sender,
        amount: amount, 
        description: description,
        approved-votes: u0,
        rejected-votes: u0,
        status: "pending"
      }
    )
    (ok claim-id)
  )
)

(define-public (vote-on-claim (claim-id uint) (approve bool))
  (let (
    (claim (unwrap! (map-get? claims {claim-id: claim-id}) (err ERR-CLAIM-NOT-FOUND)))
    (pool (unwrap! (map-get? pools {pool-id: (get pool-id claim)}) (err ERR-POOL-NOT-FOUND)))
  )
    (map-set claims
      { claim-id: claim-id }
      (merge claim {
        approved-votes: (if approve 
                        (+ (get approved-votes claim) u1)
                        (get approved-votes claim)),
        rejected-votes: (if (not approve)
                        (+ (get rejected-votes claim) u1) 
                        (get rejected-votes claim))
      })
    )
    (ok true)
  )
)

;; Read only functions
(define-read-only (get-pool-info (pool-id uint))
  (ok (map-get? pools {pool-id: pool-id}))
)

(define-read-only (get-claim-info (claim-id uint))
  (ok (map-get? claims {claim-id: claim-id}))
)
