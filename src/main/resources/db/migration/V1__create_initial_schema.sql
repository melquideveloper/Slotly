CREATE TABLE organizations (
    id UUID PRIMARY KEY,
    name VARCHAR(150) NOT NULL,
    slug VARCHAR(100) NOT NULL UNIQUE,
    status VARCHAR(30) NOT NULL DEFAULT 'ACTIVE',
    timezone VARCHAR(60) NOT NULL DEFAULT 'America/Sao_Paulo',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE users (
    id UUID PRIMARY KEY,
    name VARCHAR(150) NOT NULL,
    email VARCHAR(180) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    status VARCHAR(30) NOT NULL DEFAULT 'ACTIVE',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE memberships (
    id UUID PRIMARY KEY,
    organization_id UUID NOT NULL,
    user_id UUID NOT NULL,
    role VARCHAR(30) NOT NULL,
    status VARCHAR(30) NOT NULL DEFAULT 'ACTIVE',

    CONSTRAINT fk_membership_organization
        FOREIGN KEY (organization_id)
        REFERENCES organizations(id),

    CONSTRAINT fk_membership_user
        FOREIGN KEY (user_id)
        REFERENCES users(id),

    CONSTRAINT uk_membership
        UNIQUE (organization_id, user_id)
);

CREATE INDEX idx_membership_user
    ON memberships(user_id);

CREATE INDEX idx_membership_organization
    ON memberships(organization_id);