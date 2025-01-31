;; CrowdHaven Token Contract

(define-fungible-token haven-token)

(define-constant contract-owner tx-sender)
(define-constant ERR-NOT-AUTHORIZED (err u101))

;; Token management
(define-public (mint (amount uint) (recipient principal))
  (if (is-eq tx-sender contract-owner)
    (ft-mint? haven-token amount recipient)
    (err ERR-NOT-AUTHORIZED)
  )
)

(define-public (transfer (amount uint) (recipient principal))
  (ft-transfer? haven-token amount tx-sender recipient)
)
