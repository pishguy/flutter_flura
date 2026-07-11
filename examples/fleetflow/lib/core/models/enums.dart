enum OrderStatus {
  draft,
  submitted,
  awaitingPayment,
  paid,
  dispatching,
  assigned,
  technicianEnRoute,
  arrived,
  inProgress,
  awaitingCustomerConfirmation,
  completed,
  cancelled,
  failed,
  refunded,
}

enum PaymentStatus { pending, paid, failed, refunded }

enum UserRole { superAdmin, tenantOwner, dispatcher, technician, customer, accountant, supportAgent }
